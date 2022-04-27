defmodule Arnold.Statistics.Correlation do
  @moduledoc false

  @threshold 0.6

  @spec analyse(sensor :: Arnold.Database.Table.Sensor.t | nil, node_id :: binary, sensor_id :: binary, tag :: Arnold.Sensor.tag, prediction :: Arnold.NeuralNetwork.prediction) :: {nil, nil} | {msg :: binary, map}
  def analyse(nil, _, _, _, _) do
    {nil, nil}
  end

  def analyse(sensor, node_id, current_sensor_id, tag, prediction) do
    [latest_value | _ ] = Map.get(sensor, tag)
    alarm = Arnold.Statistics.Basic.analyse(prediction, latest_value)
    case alarm do
      {nil, nil} -> alarm

      {:alarm, msg} ->
        metrics = Arnold.Manager.get_metrics(node_id)
        x = Arnold.Sensor.values(Map.get(sensor, tag))
        corr_msg =
          Enum.reduce(metrics, %{positive: [], negative: []},
            fn
              sensor_id, acc when sensor_id != current_sensor_id ->
                sensor_y = Arnold.Utilities.id(node_id, sensor_id) |> Arnold.Sensor.get
                y = Arnold.Sensor.values(Map.get(sensor_y, tag))
                case Arnold.Statistics.Correlation.linear(x,y) |> Nx.to_number do
                  value when value > @threshold ->
                    %{acc | positive: [sensor_id | acc.positive]}
    #              value when value < -0.7 ->
    #                %{acc | negative: [s_id | acc.negative]}
                  _ -> acc
                end
              _, acc -> acc
          end)
        {msg, corr_msg}
    end
  end

  def linear(x,y) when length(x) == length(y) do
    case Enum.all?(y, &(&1 == 0)) do
      false -> do_linear(Nx.tensor(x), Nx.tensor(y))
      _ -> Nx.tensor(0)
      end
  end

  def linear(_,_) do
    Nx.tensor(0)
  end

  def acf(x) do
    n = Nx.size(x)
    k  = n/2 |> round # lag
    var = Arnold.Statistics.Math.variance(x)
    mean = Nx.mean(x)
    autocovariance(Nx.subtract(x, mean), n, k, []) |> autocorrelation(var)
  end

  defp do_linear(x,y) do
    n = Nx.size(x)


    cov = x |> Nx.subtract(Nx.mean(x)) |> Nx.multiply(Nx.subtract(y, Nx.mean(y)))|> Nx.sum |> Nx.divide(n)

    [std_multiplied] = Nx.multiply(Nx.standard_deviation(x), Nx.standard_deviation(y)) |> Nx.to_flat_list()
    case std_multiplied != 0 do
      true ->
        Nx.divide(cov, std_multiplied)
      _ ->
        Nx.tensor(0)
    end

  end

  defp autocovariance(_x, _n, k, acc) when k == 0 do
    acc
    |> Nx.tensor
  end

  defp autocovariance(x, n, k, acc) do
    i = k
    v = Nx.dot(x[k..n-1], x[i-k..n-k-1]) |> Nx.divide(n) |> Nx.to_number
    autocovariance(x, n, k-1, [v | acc])
  end

  defp autocorrelation(x, s0) do
    x |> Nx.divide(s0)
  end

end
