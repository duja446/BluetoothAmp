defmodule BluetoothAmpWeb.MyComponents do
  use Phoenix.Component
  import BluetoothAmpWeb.LiveHelpers

  attr :bg, :string, required: true
  attr :icon_name, :string, required: true
  attr :icon_type, :string, required: true
  attr :text, :string, required: true
  def page_header(assigns) do
~H"""
  <div class="flex justify-between items-center px-3">
    <div class="flex gap-4 h-11 items-center ">
      <div class={"rounded-full h-11 w-11 flex justify-center items-center #{@bg} p-2"}>
        <FontAwesome.LiveView.icon name={@icon_name} type={@icon_type} class={"h-9 w-9 fill-white"}/>
      </div>
      <p class="text-2xl font-bold"><%= @text %></p>
    </div>
    <.link navigate="/">
      <div class="rounded-full h-11 w-11 flex justify-center items-center bg-zinc-700 p-2">
        <FontAwesome.LiveView.icon name="arrow-left-long" type="solid" class={"h-9 w-9 fill-white"}/>
      </div>
    </.link>
  </div>
"""
  end

  attr :id, :any, required: true
  attr :name, :string, required: true
  attr :cover, :string, required: true
  def album_card(assigns) do
~H"""
    <.link navigate={"/albums/#{@id}"}>
      <div>
        <img src={FileServer.get_url(@cover)} class="rounded-xl h-full w-full"/>
        <p class="font-bold"><%= cut_text(@name) %></p>
      </div>
    </.link>
    """
  end

  attr :album_list, :map, required: true
  def album_grid(assigns) do
~H"""    
  <div class="grid grid-cols-2 gap-y-8 gap-x-6 p-4">
    <%= for album <- @album_list do %>
      <.album_card id={album.id} name={album.name} cover={album.cover}/>
    <% end %>
  </div>
"""
  end
end
