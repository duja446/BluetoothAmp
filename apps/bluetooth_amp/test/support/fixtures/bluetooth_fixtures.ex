defmodule BluetoothAmp.BluetoothFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BluetoothAmp.Bluetooth` context.
  """

  @doc """
  Generate a devices.
  """
  def devices_fixture(attrs \\ %{}) do
    {:ok, devices} =
      attrs
      |> Enum.into(%{
        mac: "some mac",
        name: "some name"
      })
      |> BluetoothAmp.Bluetooth.create_devices()

    devices
  end

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        mac: "some mac",
        name: "some name"
      })
      |> BluetoothAmp.Bluetooth.create_device()

    device
  end

  @doc """
  Generate a controller.
  """
  def controller_fixture(attrs \\ %{}) do
    {:ok, controller} =
      attrs
      |> Enum.into(%{
        mac: "some mac"
      })
      |> BluetoothAmp.Bluetooth.create_controller()

    controller
  end
end
