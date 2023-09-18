defmodule BluetoothAmpWeb.Music.AlbumLive do
  alias BluetoothAmp.Music
  require Logger
  use BluetoothAmpWeb, :live_view

  def mount(%{"id" => id}, _, socket) do
    album = Music.get_album_full!(id)
    {:ok, 
      socket
      |> assign_album(album)
    } 
  end

  def assign_album(socket, album) do
    assign_new(socket, :album, fn -> album end)
  end

  def handle_event("play", %{"song_id" => id}, socket) do
    song = Music.get_song_full!(id)
    Player.Server.play_song(song)
    {:noreply, socket}
  end

  def album_info(%{songs: songs, year_of_release: year_of_release}) do
    number_of_songs = Enum.count(songs)
    total_duration = Enum.reduce(songs, 0, fn %{duration: duration}, acc -> duration + acc end) |> duration_str()
    "#{number_of_songs} | #{total_duration} | #{year_of_release}"
  end

end
