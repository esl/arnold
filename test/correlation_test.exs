defmodule ArnoldCorrelationTest do
  use ExUnit.Case, async: true

  test "total_negative_linear_correlation_test" do
    assert Arnold.Statistics.Correlation.linear([1,2,3,4,5,6,7,8,9,10],[10,9,8,7,6,5,4,3,2,1]) == Nx.tensor(-1.0)
  end

  test "negative_linear_correlation_test" do
    assert Arnold.Statistics.Correlation.linear([1,2,3,4,5,6,7,8,9,10],[10,10,19,7,7,7,5,5,5,1]) == Nx.tensor(-0.735680878162384)
  end

  test "zero_linear_correlation_test" do
    assert Arnold.Statistics.Correlation.linear([1,1,1,1,1,1,1,1,1,1],[10,10,19,7,7,7,5,5,5,1]) == Nx.tensor(0)
  end

  test "positive_linear_correlation_test" do
    assert Arnold.Statistics.Correlation.linear([1,2,3,4,5,6,7,8,9,10],[1,1,1,2,3,4,7,8,9,20]) == Nx.tensor(0.8658294081687927)
  end

  test "total_positive_linear_correlation_test" do
    assert Arnold.Statistics.Correlation.linear([1,2,3,4,5,6,7,8,9,10],[1,2,3,4,5,6,7,8,9,10]) == Nx.tensor(1.0)
  end

end
