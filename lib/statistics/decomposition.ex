defmodule Arnold.Statistics.Decomposition do
  @moduledoc """
  Decompose the input values into trend and seasonality.
  """

  @window 15

  @doc """
  Decompose uses a multiplicative decomposition method.

  `InputData = Trend * Seasonality * Noise`
  The function returns a 3-element tuple, which contains where
  the the first element is the trend, followed by seasonality,
  then noise for the last place.

  For more information checkout this page:
  https://otexts.com/fpp2/components.html
  """
  @doc since: "0.5.4"
  @spec execute(input :: Nx.Tensor.t | list) :: {Nx.Tensor.t(), [Nx.Tensor.t()], Nx.Tensor.t()}
  def execute(input) when is_list(input) do
    input |> Nx.tensor |> execute
  end

  def execute(input) do
    {trend, untrended} = trend(input)
    {seasonal, residual} =  seasonality(untrended)
    #    ft = strength(residual, Nx.multiply(residual, Nx.mean(trend))) |> IO.inspect
    #    fs = strength(residual, untrended) |> IO.inspect
    {trend, seasonal, residual}
  end

  def trend(input) do
    trend = input |> Arnold.Statistics.Math.sma(@window)
    st = div(15,2)
    e = Nx.size(input) - div(15,2) - 1
    rest = Nx.subtract(input[st..e], trend)
    {trend, rest}
  end

  defp seasonality(input) do
    input
    |> seasonal_average(0, Nx.size(input) - 1, [], [])
  end

  defp seasonal_average(_input, k, n, acc_seasonal, acc_noise) when (k+@window-1) >= n do
    s =
      acc_seasonal
      |> Nx.tensor
      |> Nx.reverse
    r =
      acc_noise
      |> Nx.concatenate
      |> Nx.reverse
    {s, r}
  end

  defp seasonal_average(input, k, n, acc_seasonal, acc_res) do
    case (input[k..k+@window-1] |> Nx.not_equal(0) |> Nx.sum |> Nx.to_number) == 0 do
      true ->
        seasonal_average(input, k + @window, n, [0 | acc_seasonal], [input[k..k+@window-1] | acc_res])
      _ ->
        s =
          input[k..k+@window-1]
          |> Nx.mean
          |> Nx.to_number
        r = Nx.divide(input[k..k+@window-1], s) |> Nx.reverse
        seasonal_average(input, k + @window, n, [s | acc_seasonal], [r | acc_res])
    end
  end

end
