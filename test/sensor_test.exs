defmodule ArnoldSensorTest do
  use ExUnit.Case, async: true
  # doctest Arnold.Sensor

  @timepstamp 1642433780

  test "new_sensor_with_integer_test" do
    uuid = Arnold.Utilities.id("node", "sensor_id")
    expected_result = %Arnold.Database.Table.Sensor{
      __meta__: Memento.Table,
      id: "2cf4f805-3edb-5579-b231-11cc06744b48",
      daily: [],
      hourly: [{@timepstamp, 5}],
      predictions: %{daily: [[], [], [], []], hourly: [[], [], [], []], weekly: [[], [], [], []]}, weekly: []}
    assert Arnold.Sensor.new(uuid, @timepstamp, 5) == expected_result
  end

  test "new_sensor_with_float_test" do
    uuid = Arnold.Utilities.id("node", "sensor_id")
    expected_result = %Arnold.Database.Table.Sensor{
      __meta__: Memento.Table,
      id: "2cf4f805-3edb-5579-b231-11cc06744b48",
      daily: [],
      hourly: [{@timepstamp, 5.0}],
      predictions: %{daily: [[], [], [], []], hourly: [[], [], [], []], weekly: [[], [], [], []]}, weekly: []}
    assert Arnold.Sensor.new(uuid, @timepstamp, 5.0) == expected_result
  end

  test "new_sensor_with_invalid_value_test" do
    uuid = Arnold.Utilities.id("node", "sensor_id")
    try do
      Arnold.Sensor.new(uuid, @timepstamp, "5")
    rescue
      e ->
        assert e == %ArgumentError{message: "Invalid argument while creating sensor"}
    end
  end

  test "update_sensor_with_integer_test" do
    uuid = Arnold.Utilities.id("node", "sensor_id")
    timestamp_update = @timepstamp + 60
    expected_result = %Arnold.Database.Table.Sensor{
      __meta__: Memento.Table,
      id: "2cf4f805-3edb-5579-b231-11cc06744b48",
      daily: [],
      hourly: [{timestamp_update, 6}, {@timepstamp, 5}],
      predictions: %{daily: [[], [], [], []], hourly: [[], [], [], []], weekly: [[], [], [], []]}, weekly: []}
    sensor = Arnold.Sensor.new(uuid, @timepstamp, 5)
    assert Arnold.Sensor.update(sensor, timestamp_update, 6) == expected_result
  end

  test "update_sensor_with_float_test" do
    uuid = Arnold.Utilities.id("node", "sensor_id")
    timestamp_update = @timepstamp + 60
    expected_result = %Arnold.Database.Table.Sensor{
      __meta__: Memento.Table,
      id: "2cf4f805-3edb-5579-b231-11cc06744b48",
      daily: [],
      hourly: [{timestamp_update, 6.0}, {@timepstamp, 5}],
      predictions: %{daily: [[], [], [], []], hourly: [[], [], [], []], weekly: [[], [], [], []]}, weekly: []}
    sensor = Arnold.Sensor.new(uuid, @timepstamp, 5)
    assert Arnold.Sensor.update(sensor, timestamp_update, 6.0) == expected_result
  end

  test "update_sensor_with_invalid_value_test" do
    uuid = Arnold.Utilities.id("node", "sensor_id")
    timestamp_update = @timepstamp + 60
    sensor = Arnold.Sensor.new(uuid, @timepstamp, 5)
    try do
      Arnold.Sensor.update(sensor, timestamp_update, "6")
    rescue
      e ->
        assert e == %ArgumentError{message: "Invalid argument while updating sensor"}
    end
  end

  test "put_sensor_with_integer_test" do
    expected_result = %Arnold.Database.Table.Sensor{
      __meta__: Memento.Table,
      id: "2cf4f805-3edb-5579-b231-11cc06744b48",
      daily: [],
      hourly: [{@timepstamp, 5}],
      predictions: %{daily: [[], [], [], []], hourly: [[], [], [], []], weekly: [[], [], [], []]}, weekly: []}
    assert Arnold.Sensor.put("node", "sensor_id", @timepstamp, 5) == expected_result
    Arnold.Sensor.delete("2cf4f805-3edb-5579-b231-11cc06744b48")
  end

  test "put_sensor_with_float_test" do
    expected_result = %Arnold.Database.Table.Sensor{
      __meta__: Memento.Table,
      id: "2cf4f805-3edb-5579-b231-11cc06744b48",
      daily: [],
      hourly: [{@timepstamp, 5.0}],
      predictions: %{daily: [[], [], [], []], hourly: [[], [], [], []], weekly: [[], [], [], []]}, weekly: []}
    assert Arnold.Sensor.put("node", "sensor_id", @timepstamp, 5.0) == expected_result
    Arnold.Sensor.delete("2cf4f805-3edb-5579-b231-11cc06744b48")
  end

  test "list_test" do
    uuid0 = Arnold.Utilities.id("node", "sensor_id0")
    uuid1 = Arnold.Utilities.id("node", "sensor_id1")
    uuid2 = Arnold.Utilities.id("node", "sensor_id2")

    sensor0 = Arnold.Sensor.put("node", "sensor_id0", @timepstamp, 5)
    sensor1 = Arnold.Sensor.put("node", "sensor_id1", @timepstamp, 6)
    sensor2 = Arnold.Sensor.put("node", "sensor_id2", @timepstamp, 7)

    assert Arnold.Sensor.all() == [sensor0, sensor2, sensor1]

    for uuid <- [uuid0, uuid1, uuid2], do: assert :ok == Arnold.Sensor.delete(uuid)

  end

  test "values_test" do
    uuid = Arnold.Utilities.id("node", "sensor_id")
    sensor =
      Arnold.Sensor.new(uuid, @timepstamp, 5)
      |> Arnold.Sensor.update(@timepstamp + 60, 6)
      |> Arnold.Sensor.update(@timepstamp + 120, 7)
      |> Arnold.Sensor.update(@timepstamp + 180, 8)

    assert Arnold.Sensor.values(sensor.hourly) == [8,7,6,5]
    assert Arnold.Sensor.values(sensor.daily) == []
    assert Arnold.Sensor.values(sensor.weekly) == []

  end


  test "get_sensor_test" do
    expected_result = %Arnold.Database.Table.Sensor{
      __meta__: Memento.Table,
      id: "2cf4f805-3edb-5579-b231-11cc06744b48",
      daily: [],
      hourly: [{@timepstamp, 5}],
      predictions: %{daily: [[], [], [], []], hourly: [[], [], [], []], weekly: [[], [], [], []]}, weekly: []}
    assert Arnold.Sensor.put("node", "sensor_id", @timepstamp, 5) == expected_result
    assert Arnold.Sensor.get("2cf4f805-3edb-5579-b231-11cc06744b48") == expected_result
    Arnold.Sensor.delete("2cf4f805-3edb-5579-b231-11cc06744b48")
  end

  test "get_not_available_sensor_test" do
    assert Arnold.Sensor.get("2cf4f805-3edb-5579-b231-11cc06744b48") == nil
  end


end
