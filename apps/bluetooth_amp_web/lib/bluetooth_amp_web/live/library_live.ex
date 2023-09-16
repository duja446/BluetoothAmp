defmodule BluetoothAmpWeb.LibraryLive do
  use BluetoothAmpWeb, :live_view
  import Phoenix.Component
  alias BluetoothAmp.Scan
  
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :scan_loading, false)}
  end

  def handle_event("scan", _, socket) do
    send(self(), :run_scan)
    {:noreply, assign(socket, :scan_loading, true)}
  end

  def handle_info(:run_scan, socket) do
    Scan.run()
    {:noreply, socket |> assign(:scan_loading, false) |> push_redirect(to: "/albums")}
  end

  def bluetooth_button(%{bg_color: _} = assigns) do
  ~H"""
    <.link navigate="/bluetooth">
    <div class="flex gap-4 h-9 items-center cursor-pointer">
      <div class={"rounded-full h-11 w-11 flex justify-center items-center #{@bg_color}"}>
        <FontAwesome.LiveView.icon name="bluetooth-b" type="brands" class={"w-5 fill-white"}/>
      </div>
      <p class="text-xl font-bold">Bluetooth configuration</p>
    </div>
    </.link>
    """      
  end

  def scan_button(%{bg_color: _} = assigns) do
  ~H"""
    <div class="flex gap-4 h-9 items-center cursor-pointer" phx-click="scan">
      <div class={"rounded-full h-11 w-11 flex justify-center items-center #{@bg_color}"} phx-click="scan">
        <FontAwesome.LiveView.icon name="arrows-rotate" type="solid" class={"w-6 fill-white #{if @scan_loading, do: 'animate-spin', else: ''}"}/>
      </div>
      <p class="text-xl font-bold">Scan for music</p>
    </div>
    """      
  end

  def page_card(%{icon_name: _, icon_color: _, bg_color: _, text: _, redirect: _} = assigns) do
~H"""
    <.link navigate={@redirect}>
      <div class="flex gap-4 h-9 items-center">
        <div class={"rounded-full w-11 h-11 flex items-center justify-center #{@bg_color}"}>
          <FontAwesome.LiveView.icon name={@icon_name} type="solid" class={"w-6 #{@icon_color}"} />
        </div>
        <p class="text-xl font-bold"><%= @text %></p>
      </div>
    </.link>
    """ 
  end

end
