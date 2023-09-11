defmodule BluetoothAmpWeb.Bluetooth.Button do
  use BluetoothAmpWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("scan", _, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
  ~H"""
    <button class="rounded-full bg-blue-800 border-gray-700 border-2 h-8 w-8 flex justify-center items-center hover:scale-110 ease-in duration-200" phx-click="scan">
      <FontAwesome.LiveView.icon name="bluetooth-b" type="brands" class="h-6 fill-zinc-400"/>
    </button>
    """      
  end

end
