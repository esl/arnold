defmodule Arnold.Utilities.Benchmark do
  @moduledoc """
  Collection of benchmark functions
  """
  @moduledoc since: "0.0.1"

  @doc """
  Measure the execution time of a given function in seconds.

  ## Example
  ```
  iex(1)> Arnold.Utilities.Benchmark.measure(fn -> 2 + 5 end)
  5.0e-6
  iex(2)>
  ```
  """
  @doc since: "0.0.1"
  @spec measure(function :: function()) :: float
  def measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end
