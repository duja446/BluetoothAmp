defmodule BluetoothAmpWeb.Music.AllSongsLive do
  use BluetoothAmpWeb, :live_view

  def mount(_, _, socket) do
    {:ok, assign_new(socket, :songs, fn -> BluetoothAmp.Music.list_songs_with_album() end)}
  end

  def handle_event("play", %{"song_id" => id}, socket) do
    song = BluetoothAmp.Music.get_song_full!(id)
    Player.Server.play_song(song)
    {:noreply, socket}
  end
end
