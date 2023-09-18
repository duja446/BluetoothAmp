defmodule BluetoothAmpWeb.Music.CurrentSongLive do
  use BluetoothAmpWeb, :live_view
  require Logger
  
  def mount(_params, _session, socket) do
    Logger.debug("!!!!!!! current song mounted !!!!!!!!!!!!!1")
    if connected?(socket) do
      BluetoothAmpWeb.Endpoint.subscribe("player_state")
    end
    {:ok, 
      socket
      |> assign_new(:current_song, fn -> Player.Server.get_current_song() end)
      |> assign_new(:playing?, fn -> Player.Server.get_playing?() end)
    }
  end

  def handle_info({:current_song, song}, socket) do
    {:noreply, assign(socket, :current_song, song) |> assign(:playing?, true)}
  end

  def handle_event("continue-pause", _, socket) do
    p = socket.assigns[:playing?]
    case p do
      true -> Player.Server.pause()
      false -> Player.Server.continue()
    end
    {:noreply, assign(socket, :playing?, ! p)}
  end

end
