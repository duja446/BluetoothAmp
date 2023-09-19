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
      |> assign_new(:expanded?, fn -> false end)
      |> assign_new(:current_song, fn -> Player.Server.get_current_song() end)
      |> assign_new(:playing?, fn -> Player.Server.get_playing?() end)
      |> assign_new(:current_time, fn -> 0 end)
    }
  end

  def handle_info({:current_song, song}, state) do
    {:noreply, assign(state, :current_song, song) |> assign(:playing?, true)}
  end

  def handle_info({:stats, info}, socket) do
    current_time = socket.assigns[:current_time]
    elapsed = Map.get(info, :elapsed, current_time)
    Logger.debug("new elapsed #{inspect elapsed}")
    {:noreply, assign(socket, :current_time, elapsed) |> push_event("current_time", %{current_time: elapsed})}
  end

  def handle_event("continue-pause", _, socket) do
    p = socket.assigns[:playing?]
    case p do
      true -> Player.Server.pause()
      false -> Player.Server.continue()
    end
    {:noreply, assign(socket, :playing?, ! p)}
  end

  def handle_event("expand", _, socket) do
    {:noreply, assign(socket, :expanded?, true)}
  end

  def get_peaks() do
    File.read!("/home/duja-pc/Music/test.json") |> JSON.decode!() |> Map.get("data")
  end

  def handle_event("click", _, socket) do
    peaks = get_peaks()
    Logger.debug(inspect peaks)
    {:noreply, push_event(socket, "peaks", %{peaks: peaks}) }
  end

  def handle_event("seeking", time, socket) do
    Logger.debug("Seeking #{time}")
    Player.Server.seek_to(time)
    {:noreply, socket}
  end

end
