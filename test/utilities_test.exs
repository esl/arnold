defmodule ArnoldUtilitiesTest do
  use ExUnit.Case, async: true
  doctest Arnold.Utilities

  @uuid "2cf4f805-3edb-5579-b231-11cc06744b48"

  test "id_generation_with_binaries_test" do
    assert Arnold.Utilities.id("node", "sensor_id") == @uuid
  end

  test "id_generation_with_invalid_arguments_test" do
    try do
      assert Arnold.Utilities.id("node", :sensor_id) == @uuid
    rescue
      e -> assert e == %ArgumentError{message: "Invalid argument. Check if both parameters are binaries or strings"}
    end
  end

  test "integer_to_bool_test" do
    assert Arnold.Utilities.integer_to_boolean(1) == :true
    assert Arnold.Utilities.integer_to_boolean(0) == :false
    assert Arnold.Utilities.integer_to_boolean("1") == :false
  end

  test "normalize_test" do
    assert Arnold.Utilities.normalize(10,0,100) == 0.1
  end

end
