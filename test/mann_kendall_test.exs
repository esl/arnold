defmodule ArnoldMannKendallTest do
  use ExUnit.Case, async: true

  test "ascending_trend_test" do
    {_n, 0.05, _, _, _, z_score, _p, trend} =
      Nx.tensor([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20])
      |> Arnold.Statistics.MannKendall.execute()
    assert Nx.to_number(z_score) > 0
    assert trend == true
  end

  test "descending_trend_test" do
    {_n, 0.05, _, _, _, z_score, _p, trend} =
      Nx.tensor([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20])
      |> Nx.reverse()
      |> Arnold.Statistics.MannKendall.execute()
    assert Nx.to_number(z_score) < 0
    assert trend == true
  end

  test "constant_test" do
    {_n, 0.05, _, _, _, z_score, _p, trend} =
      Nx.tensor([1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1])
      |> Nx.reverse()
      |> Arnold.Statistics.MannKendall.execute()
    assert Nx.to_number(z_score) == 0
    assert trend == false
  end

  test "oscillating_test" do
    {_n, 0.05, _, _, _, z_score, _p, trend} =
      Nx.tensor([1,10,1,10,1,10,1,10,1,10,1,10,1,10,1,10,1,10,1,10])
      |> Arnold.Statistics.MannKendall.execute()
    assert Nx.to_number(z_score) >= 0
    assert trend == false
  end

end
