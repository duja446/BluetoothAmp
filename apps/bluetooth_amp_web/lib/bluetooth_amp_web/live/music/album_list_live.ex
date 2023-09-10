defmodule BluetoothAmpWeb.Music.AlbumListLive do
  use BluetoothAmpWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end
  
  def album_card(%{id: _, name: _, cover: _} = assigns) do
~H"""
    <a href={"/albums/#{@id}"}>
      <img src={BluetoothAmpWeb.B3.get_url(@cover)} class="rounded-xl"/>
      <p class="font-bold"><%= cut_text(@name) %></p>
    </a>
    """
  end
end
