defmodule Arnold.Statistics.Math do
  @moduledoc """
  Collection of commonly used mathematical/statistic functions.
  """

  @doc """
  Simple Moving Average algorithm

  Calculation that is used to analyze data points by creating a series of averages of
  different subsets of the full data set.

  ## Example
  ```
  iex(1)> Nx.tensor([1,2,3,4,5,6]) |> Arnold.Analyser.Math.sma(2)
  #Nx.Tensor<
    f32[5]
    [1.5, 2.5, 3.5, 4.5, 5.5]
  >
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec sma(x :: Nx.Tensor.t, window :: pos_integer) :: Nx.Tensor.t
  def sma(input, window) do
    Nx.window_mean(input, {window})
  end

  @doc """
  Estimates the variance of a sample of data.

  The variance function is a measure of heteroscedasticity and plays a large role in many settings of statistical modelling

  ## Example
  ```
  iex(1)> Nx.tensor([1,2,3,4,5,6]) |> Arnold.Analyser.Math.variance
  #Nx.Tensor<
    f32
    3.5
  >
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec variance(x :: Nx.Tensor.t) :: Nx.Tensor.t
  def variance(x) do
    x
    |> devsq
    |> Nx.divide(Nx.size(x)-1)
  end

  @doc """
  Calculates the sum of the squared deviations from the mean, without dividing by N or by N-1.

  ## Example
  ```
  iex(1)> Nx.tensor([1,2,3,4,5,6]) |> Arnold.Analyser.Math.devsq
  #Nx.Tensor<
    f32
    17.5
  >
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec devsq(x :: Nx.Tensor.t) :: Nx.Tensor.t
  def devsq(x) do
    mean = Nx.mean(x)
    x
    |> Nx.subtract(mean)
    |> Nx.power(2)
    |> Nx.sum
  end

  @doc """
  Calculates the percentage between 0 and 1 of `x` and `y`. Always the smaller number is divided by the larger.

  ## Example
  ```
  iex(1)> Arnold.Analyser.Math.percentage(5,4)
  0.8
  iex(2)> Arnold.Analyser.Math.percentage(4,5)
  0.8
  iex(3)>
  ```
  """
  @doc since: "0.5.4"
  @spec percentage(x :: number, y :: number) :: number
  def percentage(x,y) when x > y do
    y / x
  end

  def percentage(x,y) do
    x / y
  end

  def differencing(x, d, window \\ 2)
  def differencing(x, 0, _), do: x
  def differencing(x, d, window) do
    Nx.window_reduce(x, 0, {window}, fn x, acc -> Nx.subtract(x, acc) end) |> differencing(d-1, window)
  end

  @doc """
  Function for calculating the standard deviation of the given set of numbers.

  ## Example
  ```
  iex(1)> Arnold.Analyser.Math.std(Nx.tensor([4,7,2,1,6,3]))
  #Nx.Tensor<
    f32
    2.114763021469116
  >
  iex(2)>
  ```
  """
  @doc since: "0.6.0"
  @spec std(x :: Nx.Tensor.t, opts :: list) :: Nx.Tensor.t
  def std(x, opts \\ []) do
    [n | _] = Nx.shape(x) |> Tuple.to_list
    mean = Nx.mean(x, opts)

    x |> Nx.subtract(mean) |> Nx.power(2) |> Nx.sum(opts) |> Nx.divide(n) |> Nx.sqrt

  end


end
