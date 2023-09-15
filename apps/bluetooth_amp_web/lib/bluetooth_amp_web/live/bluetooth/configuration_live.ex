defmodule BluetoothAmpWeb.Bluetooth.ConfigurationLive do
  use BluetoothAmpWeb, :live_view 

  def mount(_params, _session, socket) do
    if connected?(socket) do
      BluetoothAmpWeb.Endpoint.subscribe("bluetoothctl")
    end
    {:ok,
      socket
      |> assign_new(:discovering?, fn -> false end)
      |> assign_new(:scanned_devices, fn -> MapSet.new() end)}
  end 

  def handle_info({:devices, devices}, socket) do
    {:noreply, assign(socket, :scanned_devices, devices)}
  end

  def handle_event("scan", _, socket) do
    discovering? = Map.get(socket.assigns, :discovering?)
    case discovering? do
      true -> 
        Bluetoothctl.Server.scan_off()
      false ->
        Bluetoothctl.Server.scan_on()
    end

    {:noreply, assign(socket, :discovering?, ! discovering?)}
  end

  def device_card(%{mac: _} = assigns) do
    ~H"""
    <div>
      <p class="text-2xl"><%= @mac %></p>
    </div>
    """
  end
end
