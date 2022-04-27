defmodule Arnold.NeuralNetwork do
  @moduledoc """
  The neural network API that contains function for training and prediction.
  """

  @typedoc """
  Prediction method type that can be set as the third argument of `Arnold.NeuralNetwork.predict/4`
  """
  @typedoc since: "0.5.4"
  @type prediction_method :: :simple | :complex

  @typedoc """
  Prediction result. A 4 element list of list of integers.
  1. List of timestamps
  2. List of predictions
  3. List of upper range predictions
  4. List of lower range predictions

  ```
  [[],[],[],[],[]]
  ```
  """
  @typedoc since: "0.6.2"
  @type prediction :: list(list(integer))

  @correlation_threshold 0.5

  require Logger

  @doc """
  Trains the neural network with the given `sensor` and `tag`, until a configure `eps` value is not reached.
  If it fails to reach the given epsilon value, the training stops when exceeding the `:max_iterates` config value.

  ## Example
  ```
  iex(1)> Arnold.NeuralNetwork.train(%Arnold.Database.Table.Sensor{
  ...(1)> id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
  ...(1)> hourly: [{1642593268,5},{1642593208, 6},{1642593148, 4},{1642593088, 8},{1642593028, 0}...],
  ...(1)> daily: [{1642594108, 4},{1642593808, 7},{1642593508, 2},{1642593208, 5}], weekly: []}, :hourly)
  %Arnold.Database.Table.NetworkModel{}
  iex(2)>
  ```
  """
  @doc since: "0.6.0"
  @spec train(sensor :: Arnold.Database.Table.Sensor.t) :: Arnold.Database.Table.NetworkModel.t
  def train(sensor) do
    dataset =
      Map.get(sensor, :hourly)
      |> Arnold.NeuralNetwork.Preprocess.features
      |> Arnold.NeuralNetwork.Preprocess.split
      |> Arnold.NeuralNetwork.Preprocess.normalize
      |> Arnold.NeuralNetwork.DataSet.create(32)
    model = Arnold.NeuralNetwork.Models.SingleStep.dense(dataset.features)
    model_state = Arnold.NeuralNetwork.Models.train(model, dataset.train)
    %Arnold.Database.Table.NetworkModel{id: sensor.id, dataset: dataset, model: model, model_state: model_state}
  end

  @doc """
  Predict a value or a list of values or a single value based on the method which can be `:complex` or `:simple`.
  Simple type utilizes the Single Exponential Smoothing algorithm from `Arnold.Analyser.ExponentialSmoothing.simple/1`, which is only good for predicting one value ahead.
  Complex uses neural network while also affects the results by trend and seasonality.

  If the sensor is `nil` it returns `nil`.

  ## Example
  ```
  iex(1)> Arnold.NeuralNetwork.predict(%Arnold.Database.Table.Sensor{
  ...(1)> id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
  ...(1)> hourly: [{1642594108, 4}], daily: [], weekly: []}, :hourly, 1, :simple)
  {:ok, [[1642594108], [4], [4.8], [3.2]]}
  iex(2)>
  ```
  """
  @doc since: "0.6.2"
  @spec predict(sensor :: Arnold.Database.Table.Sensor.t | nil, tag :: Arnold.Sensor.tag, horizon :: pos_integer, type :: prediction_method) :: {:ok, prediction :: prediction()}
  def predict(nil, _tag, _horizon, _method) do
    {:ok, [[],[],[],[]]}
  end

  def predict(sensor, tag, horizon, :simple = _method) do
    x = Map.get(sensor, tag) |> Arnold.Sensor.values |> Nx.tensor(type: {:f, 64})
    case Nx.size(x) >= 3 do
      true ->
        {:ok, period, _} = Arnold.Config.get(:window, tag)
        [{timestamp, _ } | _] = Map.get(sensor, tag)
        prediction =
          case has_trend_or_seasonality?(x, period) do
            {false, false} -> Arnold.Statistics.ExponentialSmoothing.simple(x, horizon) |> to_list |> Nx.tensor
            {true, false} -> Arnold.Statistics.ExponentialSmoothing.double(x, horizon)
            {_, true} -> Arnold.Statistics.ExponentialSmoothing.triple(x, period, horizon) |> to_list |> Nx.tensor
          end
        {result, result_high, result_low} = to_area(prediction)
        ts = for i <- 1..horizon, do: i*multiplier(tag)+timestamp
        merged = Arnold.Sensor.merge(sensor, tag, {ts, result, result_high, result_low})
        {:ok, merged}
      _ ->
        {:ok, [[],[],[],[]]}
    end
  end

  def predict(sensor, tag, horizon, :complex = _method) do
    {:ok, data} = Arnold.Database.get(Arnold.Database.Table.NetworkModel, sensor.id)
    [{timestamp, value} | _] = Map.get(sensor, tag)
    {ts, predictions} = do_predict(data.model, data.model_state, data.dataset.config, timestamp, value, multiplier(tag), 1, horizon, {[],[]})
    {^predictions, preds_high, preds_low} = to_area(Nx.tensor(predictions, type: {:f, 64}))
    merged = Arnold.Sensor.merge(sensor, tag, {ts, predictions, preds_high, preds_low})
    {:ok, merged}
  end

  @doc """
  Saves the given result from the `Arnold.NeuralNetwork.train/1` function.
  """
  @spec save(Arnold.Database.Table.NetworkModel.t) :: :ok
  def save(neural_network_data) do
    Arnold.Database.insert(neural_network_data)
  end

  defp do_predict(_, _, _, _, _, _, iteration, horizon, {ts_acc, forecast_acc})  when iteration > horizon do
    {Enum.reverse(ts_acc), Enum.reverse(forecast_acc)}
  end

  defp do_predict(model, model_state, config, timestamp, value, multiplier, iteration, horizon, {ts_acc, forecast_acc}) do
    prediction =
      [{timestamp, value}]
      |> Arnold.NeuralNetwork.Preprocess.features
      |> Arnold.NeuralNetwork.Preprocess.normalize_values(config[:mean], config[:std])
      |> Arnold.NeuralNetwork.Models.predict(model, model_state)
      |> Arnold.NeuralNetwork.Preprocess.revert_normalization(value, config[:mean], config[:std])
      |> Nx.to_number()
    ts = (iteration*multiplier)+timestamp
    do_predict(model, model_state, config, ts, prediction, multiplier, iteration+1, horizon, {[ts | ts_acc], [prediction | forecast_acc]})
  end

  defp to_list(x) do
    Enum.map(x, fn i -> Nx.to_number(i) end)
  end

  defp has_trend_or_seasonality?(input, period) do
    size = Nx.size(input)
    case size >= 15 do
      true ->
        {has_trend, rest} = check_trend(input)
        case size >= period do
          true ->
            has_seasonality = check_seasonality(rest)
            {has_trend, has_seasonality}
          _ ->
            {has_trend, false}
        end
      _ -> {false, false}
    end
  end

  defp check_trend(input) do
    {_, _, _, _, _, _, _, trend} = Arnold.Statistics.MannKendall.execute(input)
    if trend, do: {trend, extract_trend(input)}, else: {trend, input}
  end

  defp check_seasonality(input) do
    size = Nx.size(input) -1
    normal =
      input
      |> Nx.to_flat_list
      |> Arnold.Utilities.normalize
      |> Arnold.Utilities.normal_result
      |> Nx.tensor()
    seasonality_test(normal, size, 2, false)
  end

  defp extract_trend(input) do
    {_, rest} = Arnold.Statistics.Decomposition.trend(input)
    rest
  end

  defp seasonality_test(_input, _size, frequency, result) when frequency <= 0 do
    result
  end

  defp seasonality_test(_input, _size, frequency, true) when frequency > 0 do
    true
  end

  defp seasonality_test(input, size, frequency, _) do
    test_sin = (for i <- 0..size, do: :math.cos(i*frequency)) |> Arnold.Utilities.normalize |> Arnold.Utilities.normal_result
    test_cos = (for i <- 0..size, do: :math.sin(i*frequency)) |> Arnold.Utilities.normalize |> Arnold.Utilities.normal_result
    result1 = Arnold.Statistics.Correlation.linear(input, Nx.tensor(test_sin)) |> Nx.to_number
    result2 = Arnold.Statistics.Correlation.linear(input, Nx.tensor(test_cos)) |> Nx.to_number
    seasonality_test(input, size, frequency-0.01, (result1 >= @correlation_threshold) or (result2 >= @correlation_threshold))
  end

  defp to_area(input) do
    threshold = 0.1
    high = Nx.multiply(input, 1+threshold) |> Nx.to_flat_list
    low = Nx.multiply(input, 1-threshold) |> Nx.to_flat_list
    {input |> Nx.to_flat_list, high, low}
  end

  defp multiplier(:hourly), do: 60
  defp multiplier(:daily), do: 60*15
  defp multiplier(:weekly), do: 60*60

end
