defmodule ArnoldExponentialSmoothingTest do
  use ExUnit.Case, async: true
  doctest Arnold.Statistics.ExponentialSmoothing, except: [:moduledoc, simple: 2, triple: 3]

  test "simple_exponential_smoothing_test" do
    expected_result = [Nx.tensor(3.1514244079589844)]
    result = Nx.tensor([1,2,3,4,5,6]) |> Arnold.Statistics.ExponentialSmoothing.simple
    assert result == expected_result
  end

  test "triple_exponential_smoothing_test" do
    expected_result = [Nx.tensor(16.945600509643555), Nx.tensor(18.66143798828125), Nx.tensor(18.570167541503906), Nx.tensor(20.29241180419922), Nx.tensor(20.20764350891113), Nx.tensor(22.02154541015625), Nx.tensor(21.94183349609375)]
    result = Nx.tensor([10,11,12,13,12,11,10,11,12,14,13,11,10]) |> Arnold.Statistics.ExponentialSmoothing.triple(2,7)
    assert result == expected_result
  end

end
