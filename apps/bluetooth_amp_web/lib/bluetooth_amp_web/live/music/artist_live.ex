defmodule BluetoothAmpWeb.Music.ArtistLive do
  use BluetoothAmpWeb, :live_view

  def mount(%{"id" => id}, _, socket) do
    {:ok, assign(socket, :artist, BluetoothAmp.Music.get_artist_with_albums!(id))}
  end

  def render(assigns) do
~H"""    
  <div class="transition duration-500 ease-out opacity-0 scale-95" 
    {transition("opacity-0 scale-95", "opacity-100 scale-100")}>

    <BluetoothAmpWeb.MyComponents.page_header bg="bg-[#7CACD3]" icon_name="user" icon_type="solid" text={@artist.name} /> 

    <BluetoothAmpWeb.MyComponents.album_grid album_list={@artist.albums} />
  </div>
"""
  end
end
