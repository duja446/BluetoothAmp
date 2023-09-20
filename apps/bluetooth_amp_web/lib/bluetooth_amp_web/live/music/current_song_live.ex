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
    peaks = get_peaks(song)
    {:noreply, assign(state, :current_song, song) |> assign(:playing?, true) |> push_event("peaks", %{peaks: peaks})}
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

  def handle_event("forward", _, socket) do
    current_song = socket.assigns[:current_song]
    Player.Server.play_song(BluetoothAmp.Music.get_next_song!(current_song))
    {:noreply, socket}
  end

  def handle_event("backward", _, socket) do
    current_song = socket.assigns[:current_song]
    Player.Server.play_song(BluetoothAmp.Music.get_previous_song!(current_song))
    {:noreply, socket}
  end
  
  def handle_event("expand", _, socket) do
    Logger.debug(socket.assigns[:current_song])
    expanded? = socket.assigns[:expanded?]
    peaks = get_peaks(socket.assigns[:current_song])
    if ! expanded? do
      {:noreply, assign(socket, :expanded?, ! expanded?) |> push_event("peaks", %{peaks: peaks})}
    else
      {:noreply, assign(socket, :expanded?, ! expanded?)}
    end
  end

  def handle_event("seeking", time, socket) do
    Logger.debug("Seeking #{time}")
    Player.Server.seek_to(time)
    {:noreply, socket}
  end

  def get_peaks(song) do
    song
    |> Map.get(:waveform)
    |> :binary.bin_to_list()
  end

end
