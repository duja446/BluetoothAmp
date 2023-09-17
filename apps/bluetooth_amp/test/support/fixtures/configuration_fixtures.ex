defmodule BluetoothAmp.ConfigurationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BluetoothAmp.Configuration` context.
  """

  @doc """
  Generate a bluetooth.
  """
  def bluetooth_fixture(attrs \\ %{}) do
    {:ok, bluetooth} =
      attrs
      |> Enum.into(%{
        known_devices: "some known_devices"
      })
      |> BluetoothAmp.Configuration.create_bluetooth()

    bluetooth
  end
end
