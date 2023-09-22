defmodule BluetoothAmpWeb.Music.AlbumListLive do
  use BluetoothAmpWeb, :live_view

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def render(assigns) do
~H"""    
  <div class="transition duration-500 ease-out opacity-0 scale-95" 
    {transition("opacity-0 scale-95", "opacity-100 scale-100")}>

    <BluetoothAmpWeb.MyComponents.page_header bg="bg-[#7CACD3]" icon_name="compact-disc" icon_type="solid" text="Albums" /> 

    <BluetoothAmpWeb.MyComponents.album_grid album_list={BluetoothAmp.Music.list_albums()} />
  </div>
"""
  end
end
