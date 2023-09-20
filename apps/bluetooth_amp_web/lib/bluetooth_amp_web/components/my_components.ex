defmodule BluetoothAmpWeb.MyComponents do
  use Phoenix.Component
  import BluetoothAmpWeb.LiveHelpers

  attr :id, :any, required: true
  attr :title, :string, required: true
  attr :duration, :integer, required: true
  attr :track, :integer, required: true
  attr :album_name, :string, required: true
  attr :album_cover, :string, required: true
  def song_card(assigns) do
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
end
