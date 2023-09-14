defmodule BluetoothAmpWeb.Music.AlbumListLive do
  use BluetoothAmpWeb, :live_view

  def mount(params, session, socket) do
    {:ok, socket}
  end
  
  def album_card(%{id: _, name: _, cover: _} = assigns) do
~H"""
    <.link navigate={~p"/albums/#{@id}"}>
      <img src={FileServer.get_url(@cover)} class="rounded-xl h-full w-full"/>
      <p class="font-bold"><%= cut_text(@name) %></p>
    </.link>
    """
  end
end
