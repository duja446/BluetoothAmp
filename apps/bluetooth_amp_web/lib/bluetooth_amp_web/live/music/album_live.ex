defmodule BluetoothAmpWeb.Music.AlbumLive do
  alias BluetoothAmp.Music
  require Logger
  use BluetoothAmpWeb, :live_view

  def mount(%{"id" => id}, _, socket) do
    {:ok, 
      socket
      |> assign_new(:album, Music.get_album_full!())
    } 
  end

  def album_info(%{songs: songs, year_of_release: year_of_release}) do
    number_of_songs = Enum.count(songs)
    total_duration = Enum.reduce(songs, 0, fn %{duration: duration}, acc -> duration + acc end) |> duration_str()
    "#{number_of_songs} | #{total_duration} | #{year_of_release}"
  end

end
