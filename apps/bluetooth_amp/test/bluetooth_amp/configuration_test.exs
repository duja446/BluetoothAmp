defmodule BluetoothAmp.ConfigurationTest do
  use BluetoothAmp.DataCase

  alias BluetoothAmp.Configuration

  describe "bluetooth" do
    alias BluetoothAmp.Configuration.Bluetooth

    import BluetoothAmp.ConfigurationFixtures

    @invalid_attrs %{known_devices: nil}

    test "list_bluetooth/0 returns all bluetooth" do
      bluetooth = bluetooth_fixture()
      assert Configuration.list_bluetooth() == [bluetooth]
    end

    test "get_bluetooth!/1 returns the bluetooth with given id" do
      bluetooth = bluetooth_fixture()
      assert Configuration.get_bluetooth!(bluetooth.id) == bluetooth
    end

    test "create_bluetooth/1 with valid data creates a bluetooth" do
      valid_attrs = %{known_devices: "some known_devices"}

      assert {:ok, %Bluetooth{} = bluetooth} = Configuration.create_bluetooth(valid_attrs)
      assert bluetooth.known_devices == "some known_devices"
    end

    test "create_bluetooth/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Configuration.create_bluetooth(@invalid_attrs)
    end

    test "update_bluetooth/2 with valid data updates the bluetooth" do
      bluetooth = bluetooth_fixture()
      update_attrs = %{known_devices: "some updated known_devices"}

      assert {:ok, %Bluetooth{} = bluetooth} = Configuration.update_bluetooth(bluetooth, update_attrs)
      assert bluetooth.known_devices == "some updated known_devices"
    end

    test "update_bluetooth/2 with invalid data returns error changeset" do
      bluetooth = bluetooth_fixture()
      assert {:error, %Ecto.Changeset{}} = Configuration.update_bluetooth(bluetooth, @invalid_attrs)
      assert bluetooth == Configuration.get_bluetooth!(bluetooth.id)
    end

    test "delete_bluetooth/1 deletes the bluetooth" do
      bluetooth = bluetooth_fixture()
      assert {:ok, %Bluetooth{}} = Configuration.delete_bluetooth(bluetooth)
      assert_raise Ecto.NoResultsError, fn -> Configuration.get_bluetooth!(bluetooth.id) end
    end

    test "change_bluetooth/1 returns a bluetooth changeset" do
      bluetooth = bluetooth_fixture()
      assert %Ecto.Changeset{} = Configuration.change_bluetooth(bluetooth)
    end
  end
end
