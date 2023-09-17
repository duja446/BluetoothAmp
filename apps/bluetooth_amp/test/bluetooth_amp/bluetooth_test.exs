defmodule BluetoothAmp.BluetoothTest do
  use BluetoothAmp.DataCase

  alias BluetoothAmp.Bluetooth

  describe "devices" do
    alias BluetoothAmp.Bluetooth.Devices

    import BluetoothAmp.BluetoothFixtures

    @invalid_attrs %{mac: nil, name: nil}

    test "list_devices/0 returns all devices" do
      devices = devices_fixture()
      assert Bluetooth.list_devices() == [devices]
    end

    test "get_devices!/1 returns the devices with given id" do
      devices = devices_fixture()
      assert Bluetooth.get_devices!(devices.id) == devices
    end

    test "create_devices/1 with valid data creates a devices" do
      valid_attrs = %{mac: "some mac", name: "some name"}

      assert {:ok, %Devices{} = devices} = Bluetooth.create_devices(valid_attrs)
      assert devices.mac == "some mac"
      assert devices.name == "some name"
    end

    test "create_devices/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bluetooth.create_devices(@invalid_attrs)
    end

    test "update_devices/2 with valid data updates the devices" do
      devices = devices_fixture()
      update_attrs = %{mac: "some updated mac", name: "some updated name"}

      assert {:ok, %Devices{} = devices} = Bluetooth.update_devices(devices, update_attrs)
      assert devices.mac == "some updated mac"
      assert devices.name == "some updated name"
    end

    test "update_devices/2 with invalid data returns error changeset" do
      devices = devices_fixture()
      assert {:error, %Ecto.Changeset{}} = Bluetooth.update_devices(devices, @invalid_attrs)
      assert devices == Bluetooth.get_devices!(devices.id)
    end

    test "delete_devices/1 deletes the devices" do
      devices = devices_fixture()
      assert {:ok, %Devices{}} = Bluetooth.delete_devices(devices)
      assert_raise Ecto.NoResultsError, fn -> Bluetooth.get_devices!(devices.id) end
    end

    test "change_devices/1 returns a devices changeset" do
      devices = devices_fixture()
      assert %Ecto.Changeset{} = Bluetooth.change_devices(devices)
    end
  end

  describe "devices" do
    alias BluetoothAmp.Bluetooth.Device

    import BluetoothAmp.BluetoothFixtures

    @invalid_attrs %{mac: nil, name: nil}

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Bluetooth.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Bluetooth.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      valid_attrs = %{mac: "some mac", name: "some name"}

      assert {:ok, %Device{} = device} = Bluetooth.create_device(valid_attrs)
      assert device.mac == "some mac"
      assert device.name == "some name"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bluetooth.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      update_attrs = %{mac: "some updated mac", name: "some updated name"}

      assert {:ok, %Device{} = device} = Bluetooth.update_device(device, update_attrs)
      assert device.mac == "some updated mac"
      assert device.name == "some updated name"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Bluetooth.update_device(device, @invalid_attrs)
      assert device == Bluetooth.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = Bluetooth.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Bluetooth.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = Bluetooth.change_device(device)
    end
  end

  describe "controllers" do
    alias BluetoothAmp.Bluetooth.Controller

    import BluetoothAmp.BluetoothFixtures

    @invalid_attrs %{mac: nil}

    test "list_controllers/0 returns all controllers" do
      controller = controller_fixture()
      assert Bluetooth.list_controllers() == [controller]
    end

    test "get_controller!/1 returns the controller with given id" do
      controller = controller_fixture()
      assert Bluetooth.get_controller!(controller.id) == controller
    end

    test "create_controller/1 with valid data creates a controller" do
      valid_attrs = %{mac: "some mac"}

      assert {:ok, %Controller{} = controller} = Bluetooth.create_controller(valid_attrs)
      assert controller.mac == "some mac"
    end

    test "create_controller/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bluetooth.create_controller(@invalid_attrs)
    end

    test "update_controller/2 with valid data updates the controller" do
      controller = controller_fixture()
      update_attrs = %{mac: "some updated mac"}

      assert {:ok, %Controller{} = controller} = Bluetooth.update_controller(controller, update_attrs)
      assert controller.mac == "some updated mac"
    end

    test "update_controller/2 with invalid data returns error changeset" do
      controller = controller_fixture()
      assert {:error, %Ecto.Changeset{}} = Bluetooth.update_controller(controller, @invalid_attrs)
      assert controller == Bluetooth.get_controller!(controller.id)
    end

    test "delete_controller/1 deletes the controller" do
      controller = controller_fixture()
      assert {:ok, %Controller{}} = Bluetooth.delete_controller(controller)
      assert_raise Ecto.NoResultsError, fn -> Bluetooth.get_controller!(controller.id) end
    end

    test "change_controller/1 returns a controller changeset" do
      controller = controller_fixture()
      assert %Ecto.Changeset{} = Bluetooth.change_controller(controller)
    end
  end
end
