defmodule BluetoothAmpWeb.Bluetooth.ConfigurationLive do
  use BluetoothAmpWeb, :live_view 
  require Logger

  @error_message_show_time_ms 5_000

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
      |> assign_new(:connected_to_mac, fn -> "" end)
      |> assign_new(:error_msg, fn -> "" end)
    }
  end 

  def handle_info(:clear_error, socket) do
    {:noreply, assign(socket, :error_msg, "")}
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

  def handle_info({:connection_failed, mac}, socket) do
    send_message_to_self(:clear_error, @error_message_show_time_ms)
    {:noreply, assign(socket, :error_msg, "Can't connect to #{mac}")}
  end

  def handle_info(:disconnected, socket) do
    {:noreply, assign(socket, :connected_to_mac, "")}
  end

  def handle_info({:known_devices, known_devices}, socket) do
    Task.start(fn -> 
      Process.sleep(1500)
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
    send_message_to_self(:scan_off, 10_000)
    {:noreply, assign(socket, :discovering?, true)}
  end

  def handle_event("connect", %{"mac" => mac}, socket) do
    Bluetoothctl.Server.connect(mac)
    {:noreply, socket}
  end

  def handle_event("disconnect", _, socket) do
    Bluetoothctl.Server.disconnect()
    {:noreply, assign(socket, :connected_to_mac, "")}
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

  def handle_event("fail", _, socket) do
    send_message_to_self(:clear_error, @error_message_show_time_ms)
    {:noreply, assign(socket, :error_msg, "Can't connect to test_MAC")}
  end

  def send_message_to_self(message, delay_ms) do
    pid = self()
    Task.start(
      fn ->
        Process.sleep(delay_ms)
        send(pid, message)
      end
    )
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

  def error_popup(%{error_msg: _} = assigns) do
~H"""
    <div class="z-10 w-[70%] border-2 border-[#D87178] bg-[#C37F8D] absolute left-[15%] rounded-xl p-2 flex flex-col gap-y-2 
      transition duration-500 opacity-80 translate-y-[-100%]" {transition("opacity-80 translate-y-[-100%]", "opacity-100 translate-y-[5%]")}>
      <div class="flex gap-x-2 border-2 rounded-md w-fit px-2 py-1">
        <FontAwesome.LiveView.icon name="exclamation" type="solid" class=" h-6 fill-white" />
        <p class="font-bold">ERROR</p>
      </div>
      <p class="font-bold text-md"><%= @error_msg %></p>
    </div>
    """
  end
end
