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

  def render(assigns) do
~H"""
    <div class="transition duration-500 ease-out opacity-0 scale-95" 
      {transition("opacity-0 scale-95", "opacity-100 scale-100")}>

      <BluetoothAmpWeb.MyComponents.page_header bg="bg-[#66BABE]" icon_name="music" icon_type="solid" text="All Songs" /> 

      <div>
        <%= for song <- @songs do %>
          <BluetoothAmpWeb.MyComponents.song_card 
            title={song.name} 
            duration={song.duration} 
            track={song.track} 
            album_cover={song.album.cover} 
            album_name={song.album.name} id={song.id}
          />
        <% end %>
      </div>
    </div>

"""
  end
end
