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
      scanned_devices: %{},
      state: :standby,
      pubsub: pubsub,
      channel: channel}}
  end

  def scan_on() do
    GenServer.cast(BluetoothctlServer, {:command, :scan_on})
  end

  def scan_off() do
    GenServer.cast(BluetoothctlServer, {:command, :scan_off})
  end

  def devices() do
    GenServer.cast(BluetoothctlServer, {:command, :devices})
  end

  def connect(mac) do
    GenServer.cast(BluetoothctlServer, {:command, :connect, mac})
  end

  def connected_device() do
    GenServer.cast(BluetoothctlServer, {:command, :devices_connected})
  end

  def handle_cast({:command, :scan_on}, %{port: p} = state) do
    Port.command(p, "scan on\n")
    {:noreply, %{state | state: :scan_on}}
  end

  def handle_cast({:command, :scan_off}, %{port: p} = state) do
    Port.command(p, "scan off\n")
    {:noreply, %{state | state: :standby}}
  end

  def handle_cast({:command, :devices}, %{port: p} = state) do
    # small delay so the state is set before we get data 
    Task.start(fn -> 
      Process.sleep(1500)
      Port.command(p, "devices\n")
    end)
    {:noreply, %{state | state: :get_devices}}
  end

  def handle_cast({:command, :connect, mac}, %{port: p } = state) do
    Port.command(p, "connect #{mac}\n")
    {:noreply, %{state | state: {:attempt_connection, mac}}} 
  end

  def handle_cast({:command, :devices_connected}, %{port: p} = state) do
    Task.start(fn -> 
      Process.sleep(1500)
      Port.command(p, "devices Connected\n")
    end)
    {:noreply, %{state | state: :get_devices_connected}} 
  end

  def handle_info({_port, {:data, data}}, 
    %{scanned_devices: scanned_devices, state: :scan_on, pubsub: pubsub, channel: channel} = state) do

    data
    |> extract_info_new_device()
    |> push_new_device(pubsub, channel)

    Logger.debug(data)
    Logger.debug(String.slice(data, 25..-1//1))
    {:noreply, %{state | scanned_devices: scanned_devices}}
  end

  def handle_info({_port, {:data, data}}, 
    %{state: :get_devices, pubsub: pubsub, channel: channel} = state) do
    
    known_devices = extract_devices(data)
    Logger.debug(inspect data)
    Logger.debug(inspect known_devices)

    push_known_devices(known_devices, pubsub, channel)

    {:noreply, %{state | state: :standby}}
  end

  def handle_info({_port, {:data, data}}, 
    %{state: :get_devices_connected, pubsub: pubsub, channel: channel} = state) do
    
    Logger.debug(data)
    connected_device = extract_devices(data) |> Map.keys() |> Enum.at(0, "")
    Logger.debug(inspect connected_device)

    push_connected(connected_device, pubsub, channel)

    {:noreply, %{state | state: :standby}}
  end

  def handle_info({_port, {:data, data}}, 
    %{state: {:attempt_connection, mac}, pubsub: pubsub, channel: channel} = state) do
    
    case connection_successful?(data) do
      :yes -> push_connected(mac, pubsub, channel)
      :no -> push_connection_failed(mac, pubsub, channel)
      :no_connection_data -> ""
    end

    {:noreply, %{state | state: :standby}}
  end

  def connection_successful?(data) do
    cond do
      String.contains?(data, "Connection successful") -> :yes
      String.contains?(data, "Failed to connect") -> :no
      true -> :no_connection_data
    end
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def add_device({mac, name}, scanned_devices) do
    Map.put(scanned_devices, mac, name)
  end

  def push_connected(mac, pubsub, channel) do
    PubSub.broadcast(pubsub, channel, {:connected, mac})
  end

  def push_connection_failed(mac, pubsub, channel) do
    PubSub.broadcast(pubsub, channel, {:connection_failed, mac})
  end

  def push_new_device(nil, _, _) do
    
  end

  def push_new_device(scanned_devices, pubsub, channel) do
    PubSub.broadcast(pubsub, channel, {:scanned_device, scanned_devices})
  end

  def push_known_devices(known_devices, pubsub, channel) do
    PubSub.broadcast(pubsub, channel, {:known_devices, known_devices})
  end

  def extract_info_new_device(string) do
    s = String.split(string, " ")
    new_device? = String.contains?(Enum.at(s, 0), "NEW")
    if new_device? do
      mac = Enum.at(s, 2)
      name = Enum.join(Enum.slice(s, 3..-1//1), " ")
      name = String.slice(name, 0..-24//1)
      {mac, name}
    else
      nil
    end
  end

  def extract_info(string) do
    s = String.split(string, " ") 
    if String.equivalent?(Enum.at(s, 0), "Device") do
      mac = Enum.at(s, 1)
      name = Enum.join(Enum.slice(s, 2..-1//1), " ")
      {mac, name}
    else
      nil
    end
  end

  def extract_devices(data) do
    lines = String.split(data, "\n")
    Enum.reduce(lines, %{}, 
      fn line, acc -> 
        case extract_info(line) do
          {mac, name} -> Map.put(acc, mac, name)
          nil -> acc
        end
      end)
  end
end

