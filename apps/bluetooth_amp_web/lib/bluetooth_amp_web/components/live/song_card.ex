defmodule BluetoothAmpWeb.LiveComponents.SongCard do
  use Phoenix.LiveComponent
  import BluetoothAmpWeb.LiveHelpers

  def mount(socket) do
    {:ok, assign(socket, :liked, false)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, :song, assigns.song)}
  end

  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)

    songs = BluetoothAmp.Music.get_songs_with_album(list_of_ids) |> Map.new()

    Enum.map(list_of_assigns, fn assigns -> 
      Map.put(assigns, :song, songs[assigns.id])
    end)
  end

  def handle_event("play", %{"song_id" => id}, socket) do
    song = BluetoothAmp.Music.get_song_full!(id)
    Player.Server.play_song(song)
    {:noreply, socket}
  end

  def handle_event("like", %{"song_id" => id}, socket) do
    BluetoothAmp.Music.like_song(id)
    {:noreply, assign(socket, :song, BluetoothAmp.Music.get_song_with_album!(id))}
  end


  def render(%{song: _} = assigns) do
~H"""
    <div class="flex justify-between p-3 rounded-xl hover:bg-neutral-900">
      <div class="flex gap-x-3 w-full" phx-click="play" phx-value-song_id={@song.id} phx-target={@myself} >
        <img class="rounded-2xl w-[100px] lg:w-[200px]" src={FileServer.get_url(@song.album.cover)} />
        <div class="flex flex-col justify-evenly w-full">
          <p class="text-xl font-bold"><%= cut_text @song.name %></p>
          <p class="text-sm"><%= cut_text @song.album.name %></p>
          <div class="flex items-center">
            <FontAwesome.LiveView.icon name="guitar" type="solid" class="w-4 h-4 fill-slate-400"/>
            <p class="text-xs text-slate-400 font-semibold "><%= duration_str(@song.duration) %></p>
          </div>
        </div>
      </div>
      <div phx-click="like" phx-value-song_id={@song.id} phx-target={@myself}>
        <FontAwesome.LiveView.icon name="heart" type="solid" class={"h-6 #{if @song.liked, do: 'fill-red-300', else: 'fill-white'}"} />
      </div>
    </div>
    """
  end

end
