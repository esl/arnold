defmodule Arnold.Statistics.Basic do
  @moduledoc false

  @default_alarm {nil, nil}


  @spec analyse(prediction :: Arnold.NeuralNetwork.prediction, latest_value :: {timestamp :: integer, value :: number}) :: {nil, nil} | {:alarm, message :: binary}
  def analyse([[],[],[],[]], _) do
    @default_alarm
  end

  def analyse(prediction,  {timestamp, value} = _latest_value) do
   [timestamps, _, high_ranges, low_ranges] = prediction
   case Enum.member?(timestamps, timestamp) do
    true ->
      timestamps
      |> Enum.find_index(&(&1 == timestamp))
      |> construct_alarm(value, high_ranges, low_ranges)
   _ -> @default_alarm
   end
  end

  defp construct_alarm(idx, value, high_ranges, low_ranges) do
    high_range = Enum.at(high_ranges, idx)
    low_range = Enum.at(low_ranges, idx)
    in_range?(value, high_range, low_range)
  end

  defp in_range?(value, high, low) when value >= low and value <= high do
    {nil, nil}
  end

  defp in_range?(value, high, _) when value > high do
    {:alarm, "Current value is higher than the expected prediction range by #{value - high}"}
  end

  defp in_range?(value, _, low) when value < low do
    {:alarm, "Current value is lower than the expected prediction range by #{low - value}"}
  end

end
