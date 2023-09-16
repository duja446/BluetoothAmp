defmodule BluetoothAmpWeb.Bluetooth.ConfigurationLive do
  alias BluetoothAmpWeb.Bluetooth.ConfigurationLive
  use BluetoothAmpWeb, :live_view 
  require Logger

  def mount(_params, _session, socket) do
    Bluetoothctl.Server.devices()
    if connected?(socket) do
      BluetoothAmpWeb.Endpoint.subscribe("bluetoothctl")
    end
    {:ok,
      socket
      |> assign_new(:discovering?, fn -> false end)
      |> assign_new(:scanned_devices, fn -> %{} end)
      |> assign_new(:known_devices, fn -> %{} end)
      |> assign_new(:connected_to_mac, fn -> "" end)}
  end 

  def handle_info({:scanned_device, {mac, name}}, socket) do
    scanned_devices = 
      Map.get(socket.assigns, :scanned_devices) 
      |> Map.put(mac, name)

    {:noreply, assign(socket, :scanned_devices, scanned_devices)}
  end

  def handle_info({:connected, mac}, socket) do
    Logger.debug("CONNECTED TO: #{mac}")
    {:noreply, assign(socket, :connected_to_mac, mac)}
  end

  def handle_info({:known_devices, known_devices}, socket) do
    Task.start(fn -> 
      Process.sleep(1000)
      Bluetoothctl.Server.connected_device()
  end)
    {:noreply, assign(socket, :known_devices, known_devices)}
  end

  def handle_info(:scan_off, socket) do
    Bluetoothctl.Server.scan_off()
    {:noreply, assign(socket, :discovering?, false)}
  end

  def handle_event("scan", _, socket) do
    Bluetoothctl.Server.scan_on()
    pid = self()
    Task.start(
      fn ->
        Process.sleep(10_000)
        send(pid, :scan_off)
      end
    )
    {:noreply, assign(socket, :discovering?, true)}
  end

  def random_str(len) do
    for _ <- 1..len, into: "", do: <<Enum.random('0123456789adbcdef')>>
  end

  def handle_event("add scanned device", _, socket) do
    scanned_devices = 
      Map.get(socket.assigns, :scanned_devices)
      |> Map.put(random_str(4), random_str(10))
    {:noreply, assign(socket, :scanned_devices, scanned_devices)} 
  end

  def handle_event("connect", _, socket) do
    {:noreply, assign(socket, :connected_to_mac, "40:58:99:1A:D2:C5")}
  end


  def device_card(%{mac: _, name: _} = assigns) do
    ~H"""
    <div class="flex text-xl justify-between">
      <p>
        <span class="font-bold"><%= @mac %></span>
        <span class="mx-1">|</span>  
        <%= @name %>
      </p>
      <button class="rounded-full p-1 bg-zinc-700">
        <FontAwesome.LiveView.icon name="link" type="solid" class="w-7 h-7 fill-[#66BAEA]" />
      </button>
    </div>
    """
  end
end
