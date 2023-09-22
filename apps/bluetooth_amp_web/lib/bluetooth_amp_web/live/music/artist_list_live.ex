defmodule BluetoothAmpWeb.Music.ArtistListLive do
  use BluetoothAmpWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def artist_card(%{id: _, name: _} = assigns) do
~H"""

    <.link navigate={~p"/artists/#{@id}"}>
      <div>
        <img src={"/images/person.png"} class="mix-blend-multiply rounded-xl h-full w-full"/>
        <p class="font-bold"><%= cut_text(@name) %></p>
      </div>
    </.link>
    """
  end

  def render(assigns) do
~H"""    
  <div class="transition duration-500 ease-out opacity-0 scale-95" 
    {transition("opacity-0 scale-95", "opacity-100 scale-100")}>

    <BluetoothAmpWeb.MyComponents.page_header bg="bg-[#939DBD]" icon_name="microphone" icon_type="solid" text="Artists" /> 

    <div class="grid grid-cols-2 gap-y-8 gap-x-6 p-4">
      <%= for artist <- BluetoothAmp.Music.list_artists() do %>
        <.artist_card id={artist.id} name={artist.name} />
      <% end %>
    </div>
  </div>
"""
  end
end
