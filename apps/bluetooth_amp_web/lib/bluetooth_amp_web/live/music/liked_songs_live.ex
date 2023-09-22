defmodule BluetoothAmpWeb.Music.LikedSongsLive do
  use BluetoothAmpWeb, :live_view

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def render(assigns) do
~H"""
    <div class="transition duration-500 ease-out opacity-0 scale-95" 
      {transition("opacity-0 scale-95", "opacity-100 scale-100")}>

      <BluetoothAmpWeb.MyComponents.page_header bg="bg-[#C37F8D]" icon_name="thumbs-up" icon_type="solid" text="Liked Songs" /> 

      <div>
        <%= for song <- BluetoothAmp.Music.list_liked_songs() do %>
          <.live_component module={BluetoothAmpWeb.LiveComponents.SongCard} id={song.id} song={song}/>
        <% end %>
      </div>
    </div>

"""
  end
end
