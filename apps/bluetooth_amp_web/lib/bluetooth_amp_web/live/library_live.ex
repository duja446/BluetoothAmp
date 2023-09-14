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

  def button_classes(loading) do
    spin = if loading, do: "animate-spin", else: ""
    "h-5 fill-zinc-400 " <> spin
  end

  def scan_button(assigns) do
  ~H"""
    <div class="flex gap-4 h-9 items-center" phx-click="scan">
      <div class="rounded-full bg-gray-800 h-9 w-9 flex justify-center items-center " phx-click="scan">
        <FontAwesome.LiveView.icon name="arrows-rotate" type="solid" class={"w-5 fill-zinc-400 #{if @scan_loading, do: 'animate-spin', else: ''}"}/>
      </div>
      <p class="text-xl font-bold">Scan for music</p>
    </div>
    """      
  end

  def page_card(%{icon_name: _, icon_color: _, bg_color: _, text: _, redirect: _} = assigns) do
~H"""
    <.link navigate={@redirect}>
      <div class="flex gap-4 h-9 items-center">
        <div class={"rounded-full bg-zinc-400 w-9 h-9 flex items-center justify-center #{@bg_color}"}>
          <FontAwesome.LiveView.icon name={@icon_name} type="solid" class={"w-5 #{@icon_color}"} />
        </div>
        <p class="text-xl font-bold"><%= @text %></p>
      </div>
    </.link>
    """ 
  end

end
