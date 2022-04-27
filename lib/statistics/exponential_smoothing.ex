defmodule Arnold.Statistics.ExponentialSmoothing do
  @moduledoc """
  Collection of exponential smoothing algorithms.
  - simple (SES, or Single Exponential Smoothing)
  - double (DWA, Holts Double Exponential Smoothing, Holt’s linear trend method)
  """

  @alpha 0.2
  @beta 0.15
  @gamma 0.05

  @doc """
  Simple Exponential Smoothing algorithm.

  SES is a time series forecasting method for univariate data without a trend or seasonality.
  It requires a single parameter, which is hard coded, called alpha, also called the smoothing factor or
  smoothing coefficient.

  For more information checkout this page:
  https://otexts.com/fpp2/ses.html

  ## Example
  ```
  iex(1)> Nx.tensor([1,2,3,4,5,6]) |> Arnold.Analyser.ExponentialSmoothing.simple
  #Nx.Tensor<
    f32
    2.1164159774780273
  >
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec simple(x :: Nx.Tensor.t, horizon :: non_neg_integer()) :: [Nx.Tensor.t]
  def simple(x, horizon \\ 1) do
    y = Nx.reverse(x)
    ses(y, y[0], horizon, 0, Nx.size(x) - 1)
  end

  @doc """
  Double Exponential Smoothing algorithm.

  Double Exponential Smoothing(DWA) is also called as Holts Double Exponential Smoothing.
  Double Exponential Smoothing is extended form of Simple Exponential Smoothing. Double Exponential Smoothing technique
  is used for forecasting with trending data.It has level and trend but it does not have seasonality.

  Unlike SES, it can optionally extended with a horizon parameter which tells the algorithm how far should it look ahaed
  for forecasting.

  For more information checkout this page:
  https://otexts.com/fpp2/holt.html
  https://medium.com/@shrikantpandeymnnit2015/time-series-analysis-and-its-different-approach-in-python-part-1-714dee28041f

  ## Example
  ```
  iex(1)> Nx.tensor([10,11,12,13]) |> Arnold.Analyser.ExponentialSmoothing.double
  #Nx.Tensor<
    f32[1]
    [9.0]
  >
  iex(2)>
  ```
  """
  @doc since: "0.5.5"
  @spec double(x :: Nx.Tensor.t, horizon :: pos_integer) :: Nx.Tensor.t
  def double(x, horizon \\ 1) do
    yt = Nx.reverse(x)
    t0 = Nx.subtract(yt[1], yt[0])
    l0 = yt[1]
    holt(yt, l0, t0, horizon, 2, Nx.size(x) - 1)
  end

  @doc """
  Triple Exponential Smoothing algorithm.
  Triple Exponential Smoothing is also known as “Halt-Winters Method”. When we have the level ,trend and seasonality
  in data set then we use Triple Exponential Smoothing or Halts’ Winter Method. It is similar to Double Exponential
  Smoothing , we add one extra parameter gamma(seasonality) for Halts’ Winter Method. In Halts’ Winter Method there is
  three smoothing parameters alpha(α),beta(β),gamma(γ).

  For more information checkout this page:
  https://medium.com/@shrikantpandeymnnit2015/time-series-analysis-and-its-different-approach-in-python-part-1-714dee28041f
  https://otexts.com/fpp2/holt-winters.html

  ## Example
  ```
  iex(1)> Nx.tensor([10,11,12,13,12,11,10,11,12,14,13,11,10]) |> Arnold.Analyser.ExponentialSmoothing.triple(2,7)
  [
  #Nx.Tensor<
    f32
    13.446951866149902
  >,
  #Nx.Tensor<
    f32
    14.956113815307617
  >
  ]
  iex(2)>
  ```
  """
  @doc since: "0.5.5"
  @spec triple(x :: Nx.Tensor.t, period :: pos_integer, horizon :: pos_integer) :: [Nx.Tensor.t]
  def triple(x, period, horizon \\ 1) do
    yt = Nx.reverse(x)
    st = Nx.subtract(yt[0..(period-1)], Nx.mean(yt[0..(period-1)]))
    lt = Nx.subtract(yt[period], st[0])
    tt = Nx.subtract(lt, Nx.subtract(yt[period-1], st[period-1]))
    s = Nx.add(Nx.multiply(@gamma, Nx.subtract(yt[period], lt)), Nx.multiply(1-@gamma, st[0])) |> Nx.to_number
    seasonal = Nx.concatenate([st, Nx.tensor([s])])
    holt_winters(yt, lt, tt, seasonal, horizon, period, period + 1, Nx.size(x) - 1)
  end

  defp ses(y, forecast, horizon, iteration, limit) when iteration <= limit do
    yt = Nx.add(Nx.multiply(@alpha, y[iteration]), Nx.multiply(1-@alpha, forecast))
    ses(y, yt, horizon, iteration+1, limit)
  end

  defp ses(y, forecast, horizon, _iteration, _limit) do
   forecast(y[-1], forecast, horizon, [])
  end


  defp forecast(_, _, 0, acc), do: Enum.reverse(acc)
  defp forecast(y, forecast, horizon, acc) when horizon > 0 do
    yt = Nx.add(Nx.multiply(@alpha, y), Nx.multiply(1-@alpha, forecast))
    forecast(y, yt, horizon-1, [yt|acc])
  end

  defp holt(y, level, trend, horizon, iteration, limit) when iteration <= limit do
    yt = y[iteration]
    lt = Nx.add(Nx.multiply(yt, @alpha), Nx.multiply(1-@alpha, Nx.add(level, trend)))
    tt = Nx.add(Nx.multiply(Nx.subtract(lt, level), @beta), Nx.multiply(1-@beta, trend))
    holt(y, lt, tt, horizon, iteration + 1, limit)
  end

  defp holt(_, level, trend, horizon, _, _) do
    (for i <- 1..horizon, do: i)
    |> Nx.tensor
    |> Nx.multiply(trend)
    |> Nx.add(level)
  end

  defp holt_winters(y, level, trend, seasonal, horizon, period, iteration, limit) when iteration <= limit do
    yt = y[iteration]
    stm = seasonal[iteration - period]
    lt = Nx.add(Nx.multiply(Nx.subtract(yt,stm), @alpha), Nx.multiply(1-@alpha, Nx.add(level, trend)))
    tt = Nx.add(Nx.multiply(Nx.subtract(lt, level), @beta), Nx.multiply(1-@beta, trend))
    st = Nx.add(Nx.multiply(@gamma, Nx.subtract(yt, lt)), Nx.multiply(1-@gamma, stm)) |> Nx.to_number
    s = Nx.concatenate([seasonal, Nx.tensor([st])])
    holt_winters(y, lt, tt, s, horizon, period, iteration + 1, limit)
  end

  defp holt_winters(_, level, trend, seasonal, horizon, period, iteration, _) do
    for h <- 1..horizon do
      Nx.add(Nx.add(level, Nx.multiply(h, trend)), seasonal[iteration - period - h])
    end
  end
end
