defmodule BluetoothctlTest do
  use ExUnit.Case
  doctest Bluetoothctl

  test "greets the world" do
    assert Bluetoothctl.hello() == :world
  end
end
