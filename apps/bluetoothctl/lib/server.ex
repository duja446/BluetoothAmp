defmodule Bluetoothctl.Server do
  use GenServer
  require Logger
  alias Phoenix.PubSub

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: BluetoothctlServer)
  end

  defp connect() do
    Port.open({:spawn, "bluetoothctl"}, [:binary])
  end

  def init({pubsub, channel}) do
    PubSub.subscribe(pubsub, channel)
    port = connect()
    {:ok, %{
      port: port, 
      scanned_devices: MapSet.new(),
      discovering?: false,
      pubsub: pubsub,
      channel: channel}}
  end

  def scan_on() do
    GenServer.cast(BluetoothctlServer, {:command, "scan on\n"})
  end

  def scan_off() do
    GenServer.cast(BluetoothctlServer, {:command, "scan off\n"})
  end

  def handle_cast({:command, cmd}, %{port: p} = state) do
    Port.command(p, cmd)
    {:noreply, state}
  end

  def handle_info({_port, {:data, data}}, 
    %{scanned_devices: scanned_devices, discovering?: old_discovering?, pubsub: pubsub, channel: channel} = state) do
    discovering? = 
      case discovering?(data) do
        :yes -> true
        :no -> false
        :no_discovering_message -> old_discovering?
      end

    mac = extract_MAC(data)
    scanned_devices = add_device(discovering?, mac, scanned_devices)

    push_devices(scanned_devices, pubsub, channel)

    IO.write(data)
    IO.write("\n") 
    IO.write(extract_MAC(data))
    IO.write("\n\n") 
    {:noreply, %{state | discovering?: discovering?, scanned_devices: scanned_devices}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def add_device(true, mac, scanned_devices) do
    MapSet.put(scanned_devices, mac)
  end

  def add_device(false, _mac, scanned_devices) do
    scanned_devices
  end

  def push_devices(scanned_devices, pubsub, channel) do
    PubSub.broadcast(pubsub, channel, {:devices, scanned_devices})
  end

  def discovering?(data) do
    cond do
      String.contains?(data, "Discovering: yes") -> :yes
      String.contains?(data, "Discovering: no") -> :no
      true -> :no_discovering_message 
    end
  end

  def extract_MAC(string) do
    case Regex.run(~r/([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})/, string) do
      [hd | _] -> hd
      nil -> ""
    end
  end
end

