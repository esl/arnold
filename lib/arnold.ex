defmodule Arnold do
  @moduledoc """
  Arnold main API functions, which can be used to communicate with other nodes or applications.
  The REST Api utilizes these functions mainly.
  """
  @moduledoc since: "0.5.4"

  require Logger

  @doc"""
  Feed data to the sensors. It is going to be marked for train if the threshold is reached for the
  current input category.

  ## Example
  ```elixir
  iex(1)> Arnold.feed("node", "sensor_id", 1642433780, 5)
  :ok
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec feed(node_id :: binary, sensor_id :: binary, time :: pos_integer, value :: number) :: :ok
  def feed(node_id, sensor_id, time, value) do
    Logger.debug("Incoming message: #{node_id} - #{sensor_id}")
    try do
      Arnold.Manager.register_metric(node_id, sensor_id)
      Arnold.Sensor.put(node_id, sensor_id, time, value)
      |> maybe_mark_for_train
    catch
      :exit, e ->
        Logger.error("Could not insert or update sensor states. Reason: #{inspect(e)}")
        {:ok, _pid} = Arnold.LoadBalancer.start_new_sensor_agent
        :ok
    end
  end

  @doc"""
  Predicts a value for a given `id` and `tag`. Check out the `:windows` to see the available `tag` values.
  There are two types of predictions: `simple` and `complex`. Complex uses the trained neural network, while
  the simple is only used when there aren't any networks for the current id. It uses SES algorithm for predictions.

  ## Example
  ```
  iex(1)> Arnold.predict("node_sensor_uuid", :hourly, 5)
  {:ok,
      [[1642433780, 1642433840, 1642433900, 1642433960,1642434020],
       [119027224.0,119214032.0, 119363472.0, 119483024.0, 119578672.0],
       [107124496.0, 107292624.0, 107427120.0, 107534720.0, 1.076208e8],
       [130929952.0, 131135440.0, 131299824.0, 131431328.0, 131536544.0]]}
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec predict(uuid :: binary, tag :: Arnold.Sensor.tag, horizon :: pos_integer) :: {:ok, Arnold.NeuralNetwork.prediction}
  def predict(uuid, tag, horizon) do
    case Arnold.Manager.is_finished?(uuid, tag) do
      true ->
        Arnold.Sensor.get(uuid) |> Arnold.NeuralNetwork.predict(tag, horizon, :complex)
      false ->
        Logger.notice("Training is not finished for #{inspect(uuid)} - #{inspect(tag)}")
        Arnold.Sensor.get(uuid) |> Arnold.NeuralNetwork.predict(tag, horizon, :simple)
    end
  end

  @doc"""
  Predicts a value for a given `node`, `sensor_id` and `tag`. Check out the `:windows` to see the available `tag` values.
  Calls for `predict/2`.

  ## Example
  ```
  iex(1)> Arnold.predict("node", "sensor_id", :hourly, 5)
  {:ok, [[],[],[],[]]}
  iex(2)>
  ```
  """
  @doc since: "0.6.2"
  @spec predict(node_id :: binary, sensor_id :: binary, tag :: Arnold.Sensor.tag, horizon :: pos_integer) :: {:ok, Arnold.NeuralNetwork.prediction}
  def predict(node_id, sensor_id, tag, horizon) do
    Arnold.Utilities.id(node_id, sensor_id) |> predict(tag, horizon)
  end


  @doc"""
  Returns the correlation with each metric that was pushed for a node. If found positive or negative correlation
  for a threshold larger (or smaller) than 0.7 marks it as the metrics are correlating with each other.

  ## Example
  ```
  iex(1)> Arnold.analyse("node", "sensor_id", :hourly, [[1642433780, 1642433840, 1642433900, 1642433960,1642434020],
  ...>                                                  [119027224.0,119214032.0, 119363472.0, 119483024.0, 119578672.0],
  ...>                                                  [107124496.0, 107292624.0, 107427120.0, 107534720.0, 1.076208e8],
  ...>                                                  [130929952.0, 131135440.0, 131299824.0, 131431328.0, 131536544.0]])
  {nil, nil}
  iex(2)>
  ```
  """
  @doc since: "0.6.2"
  @spec analyse(node_id :: binary, sensor_id :: binary, tag :: Arnold.Sensor.tag, prediction :: Arnold.NeuralNetwork.prediction) :: {nil, nil} | {msg :: binary, map}
  def analyse(node_id, sensor_id, tag, prediction) do
    Arnold.Utilities.id(node_id, sensor_id)
     |> Arnold.Sensor.get
     |> Arnold.Statistics.Correlation.analyse(node_id, sensor_id, tag, prediction)
  end

#  @doc"""
#  Return the tendency value for a given `node`, `sensor_id` and `tag`. If the sensor is not found returns `nil`.
#
#  ## Example
#  ```
#  iex(1)> Arnold.tendency("node", "sensor_id", :hourly)
#  235.6
#  iex(2)>
#  ```
#  """
#  @doc since: "0.5.4"
#  @spec tendency(node_id :: binary, sensor_id :: binary, tag :: Arnold.Sensor.tag) :: number | nil
#  def tendency(node, sensor, tag) do
#    case Arnold.Utilities.id(node, sensor) |> Arnold.Sensor.Api.get do
#      nil ->
#        nil
#      sensor ->
#        sensor.tendency[tag]
#    end
#  end

#  @doc"""
#  Return the seasonality value for a given `node`, `sensor_id` and `tag`. If the sensor is not found returns `nil`.
#
#  ## Example
#  ```
#  iex(1)> Arnold.seasonality("node", "sensor_id", :hourly)
#  [1.0, 0.9, 0.8, 0.7]
#  iex(2)>
#  ```
#  """
#  @doc since: "0.5.4"
#  @spec seasonality(node_id :: binary, sensor_id :: binary, tag :: Arnold.Sensor.tag) :: list | nil
#  def seasonality(node, sensor, tag) do
#    case Arnold.Utilities.id(node, sensor) |> Arnold.Sensor.Api.get do
#      nil ->
#        nil
#      sensor ->
#        sensor.seasonality[tag]
#    end
#  end

  defp maybe_mark_for_train(sensor) do
    {:ok, windows} = Arnold.Config.get(:windows)
    Enum.map(windows,
      fn {tag, threshold} ->
      case Map.get(sensor, tag) |> Arnold.Utilities.is_constant? do
        false ->
          mark(sensor, threshold, tag)
        true ->
          Logger.debug("Skipped training marks for sensor - #{inspect(sensor.id)} - #{inspect(tag)}, because of constant values")
          {:skip, :constant}
      end
    end)
    :ok
  end

  defp mark(sensor, threshold, tag) do
      len = Map.get(sensor, tag) |> length
      case len >= threshold do
        true ->
          :ok = Arnold.Manager.mark(sensor.id, tag)
        _ ->
          Logger.debug("Not enough values for sensor - #{inspect(sensor.id)} - #{inspect(tag)}")
          {:skip, :not_enogh_values}
      end
  end

end
