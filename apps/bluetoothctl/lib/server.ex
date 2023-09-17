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
      state: :standby,
      pubsub: pubsub,
      channel: channel,
      data_buffer: <<>>}}
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

  def disconnect() do
    GenServer.cast(BluetoothctlServer, {:command, :disconnect})
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
    Port.command(p, "devices\n")
    {:noreply, %{state | state: :get_devices}}
  end

  def handle_cast({:command, :connect, mac}, %{port: p } = state) do
    Port.command(p, "connect #{mac}\n")
    {:noreply, %{state | state: {:attempt_connection, mac}}} 
  end

  def handle_cast({:command, :disconnect}, %{port: p } = state) do
    Port.command(p, "disconnect")
    {:noreply, %{state | state: :attempt_disconnection}} 
  end

  def handle_cast({:command, :devices_connected}, %{port: p} = state) do
    Port.command(p, "devices Connected\n")
    {:noreply, %{state | state: :get_devices_connected}} 
  end

  def handle_info({_port, {:data, data}},
    %{data_buffer: data_buffer} = state) do
    
    data_buffer = data_buffer <> data
    Logger.debug("DATA: #{inspect data}")
    Logger.debug("DATA BUFFER: #{inspect data_buffer}")
    if received_all(data_buffer) do
      Logger.debug("received all")
      handle_data(data_buffer, state)
      {:noreply, %{state | data_buffer: <<>>}}
    else
      Logger.debug("didnt receive all")
      {:noreply, %{state | data_buffer: data_buffer}}
    end
  end

  def handle_info(_, state) do
    {:noreply, state} 
  end

  def handle_data(data, %{state: :standby}) do
    Logger.debug("STANDBY DATA: #{inspect data}")
  end

  def handle_data(data, %{state: :scan_on, pubsub: pubsub, channel: channel}) do
    new_device = extract_info_new_device(data)
    Logger.debug("NEW DEVICE: #{inspect new_device}")
    if new_device do 
      PubSub.broadcast(pubsub, channel, {:scanned_device, new_device})
    end
  end

  def handle_data(data, %{state: :get_devices, pubsub: pubsub, channel: channel}) do
    known_devices = extract_devices(data)
    Logger.debug("KNOWN DEVICES: #{inspect known_devices}")
    PubSub.broadcast(pubsub, channel, {:known_devices, known_devices})
  end

  def handle_data(data, %{state: :get_devices_connected, pubsub: pubsub, channel: channel}) do
    connected_device_mac = extract_devices(data) |> Map.keys() |> Enum.at(0, "")
    Logger.debug("CONNECTED DEVICE #{inspect connected_device_mac}")
    PubSub.broadcast(pubsub, channel, {:connected, connected_device_mac})
  end

  def handle_data(data, %{state: {:attempt_connection, mac}, pubsub: pubsub, channel: channel}) do
    case connection_successful?(data) do
      true -> 
        Logger.debug("CONNECTION SUCCESSFUL TO: #{mac}")
        PubSub.broadcast(pubsub, channel, {:connected, mac})
      false -> 
        Logger.debug("CONNECTION UNSUCCESSFUL TO: #{mac}")
        PubSub.broadcast(pubsub, channel, {:connection_failed, mac})
      :no_connection_string -> 
        Logger.debug("NO CONNECTION STRING")
        nil
    end
  end

  def handle_data(data, %{state: :attempt_disconnection, pubsub: pubsub, channel: channel}) do
    case disconnection_successful?(data) do
      true -> PubSub.broadcast(pubsub, channel, :disconnected)
      false -> PubSub.broadcast(pubsub, channel, :disconnection_failed)
    end
  end

  def connection_successful?(data) do
    cond do
      String.contains?(data, "Connection successful") -> true
      String.contains?(data, "Failed to connect") -> false
      true -> :no_connection_string
    end
  end

  def disconnection_successful?(data) do
    cond do
      String.contains?(data, "Successful disconnected") -> true
      String.contains?(data, "Failed to disconnect") -> false
    end
  end

  def received_all(data) do
    Regex.match?(~r/\e\[0;94m\[(.*?)\]\e\[0m#/, data) 
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

