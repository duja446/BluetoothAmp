defmodule BluetoothAmpWeb.Music.AlbumLive do
  alias BluetoothAmp.Music
  require Logger
  use BluetoothAmpWeb, :live_view

  def mount(%{"id" => id}, _, socket) do
    album = Music.get_album_with_songs!(id)
    {:ok, 
      socket
      |> assign_album(album)
    } 
  end

  def assign_album(socket, album) do
    assign_new(socket, :album, fn -> album end)
  end

  def handle_event("play", %{"song_id" => id}, socket) do
    song = Music.get_song!(id)
    BluetoothAmpWeb.PlayerState.play(song)
    {:noreply, socket}
  end

  def song_card(%{id: _, title: _, duration: _, track: _, album_name: _, album_cover: _} = assigns) do
~H"""
    <div phx-click="play" phx-value-song_id={@id} class="flex m-3 gap-x-[1rem] m-0 p-3 rounded-xl mx-2 hover:bg-neutral-900">
      <img class="rounded-2xl w-[100px] lg:w-[200px]" src={FileServer.get_url(@album_cover)} />
      <div class="flex flex-col justify-evenly">
        <p class="text-xl font-bold"><%= cut_text @title %></p>
        <p class="text-sm"><%= cut_text @album_name %></p>
        <div class="flex items-center">
          <FontAwesome.LiveView.icon name="guitar" type="solid" class="w-4 h-4 fill-slate-400"/>
          <p class="text-xs text-slate-400 font-semibold "><%= duration_str(@duration) %></p>
        </div>
      </div>
    </div>
    """
  end

  defp duration_str(duration) do
    duration_s = floor(duration / 1000)
    mins = floor(duration_s / 60)
    seconds = 
      rem(duration_s, 60)
      |> pad()
    "#{mins}:#{seconds}"
  end

  defp pad(x) do
    x
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

end
