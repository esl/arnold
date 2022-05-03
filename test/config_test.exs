defmodule ArnoldConfigTest do
  use ExUnit.Case, async: true
  doctest Arnold.Config

  test "check_other_window_types_test" do
    assert Arnold.Config.get(:window, :daily) == {:ok, 192, 86400}
    assert Arnold.Config.get(:window, :weekly) == {:ok, 336, 604800}
  end

  test "configure_port_test" do
    Application.put_env(:arnold, :port, 8082)
    assert Arnold.Config.get(:port) == {:ok, 8082}
    Application.delete_env(:arnold, :port)
  end

end
