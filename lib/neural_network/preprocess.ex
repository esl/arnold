defmodule Arnold.NeuralNetwork.Preprocess do
  @moduledoc false

  @portion 0.8

  @type split_data :: %{train: Nx.Tensor.t, test: Nx.Tensor.t, features: pos_integer}

  def features(data) do
    for {timestamp, value} <- data do
      tags = time_of_tags(timestamp)
      [value | tags]
    end
    |> Nx.tensor(names: [:time, :features], type: {:f, 64})
  end

  @spec split(data :: Nx.Tensor.t) :: split_data
  def split(data) do
    {n, features} = Nx.shape(data)

    num_train = ceil(n * @portion)
    num_test = n - num_train

    train_data = Nx.slice(data, [0,0], [num_train, features])
    test_data = Nx.slice(data, [num_train, 0], [num_test, features])

    %{train: train_data, test: test_data, features: features}
  end

  @spec normalize(input :: split_data()) :: map()
  def normalize(%{train: train_data, test: test_data, features: features}) do
    opts = [axes: [:time]]

    mean = train_data |> Nx.mean(opts)
    std = train_data |> Arnold.Statistics.Math.std(opts)

    train_norm = normalize_values(train_data, mean, std)
    test_norm = normalize_values(test_data, mean, std)

    %{train: train_norm, test: test_norm, features: features, std: std, mean: mean}
  end

  def revert_normalization(prediction, data, mean, std) do
    m = mean[0]
    s = std[0]
    normalize_values(data, m, s)
    |> Nx.subtract(prediction)
    |> Nx.multiply(s)
    |> Nx.add(m)
  end



  defp time_of_tags(timestamp) do
    {:ok, _window, period_hour} = Arnold.Config.get(:window, :hourly)
    {:ok, _window, period_day} = Arnold.Config.get(:window, :daily)
    {:ok, _window, period_week} = Arnold.Config.get(:window, :weekly)
    pi = :math.pi
    hour_sin = :math.sin(timestamp * (2 * pi/period_hour))
    hour_cos = :math.cos(timestamp * (2 * pi/period_hour))
    day_sin = :math.sin(timestamp * (2 * pi/period_day))
    day_cos = :math.cos(timestamp * (2 * pi/period_day))
    week_sin = :math.sin(timestamp * (2 * pi/period_week))
    week_cos = :math.cos(timestamp * (2 * pi/period_week))
    [hour_sin, hour_cos, day_sin, day_cos, week_sin, week_cos]
  end

  def normalize_values(data, mean, std) do
    data |> Nx.subtract(mean) |> Nx.divide(std)
  end

end
