defmodule BluetoothAmpWeb.Music.ScanButton do
  use BluetoothAmpWeb, :live_view
  require Logger

  alias BluetoothAmp.Repo
  alias BluetoothAmp.Music

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :loading, false)}
  end

  def handle_event("scan", _, socket) do
    send(self, :run_scan)
    {:noreply, assign(socket, :loading, true)}
  end

  def handle_info(:run_scan, socket) do
    scan()
    {:noreply, socket |> assign(:loading, false) |> push_redirect(to: "/albums")}
  end

  def button_classes(loading) do
    spin = if loading, do: "animate-spin", else: ""
    "h-5 fill-zinc-400 " <> spin
  end

  def render(assigns) do
  ~H"""
    <button class="rounded-full bg-gray-800 border-2 border-gray-700 h-8 w-8 flex justify-center items-center hover:scale-110 ease-in duration-200" phx-click="scan">
      <FontAwesome.LiveView.icon name="arrows-rotate" type="solid" class={button_classes(@loading)}/>
    </button>
    """      
  end

  def random_str(len) do
    for _ <- 1..len, into: "", do: <<Enum.random('0123456789adbcdef')>>
  end

  def scan() do
    Logger.info(File.cwd!())
    Repo.delete_all Music.Song  
    Repo.delete_all Music.Album  
    Repo.delete_all Music.Artist

    scanned = Scanner.scan(Path.expand("~/Music/"))
    Enum.map(scanned, 
      fn {artist_name, albums_map} -> 
        {:ok, artist} = Music.create_artist(%{name: artist_name})
        Enum.map(albums_map, 
          fn {%{name: name, path: path}, songs} -> 
            cover_path = path <> "/Cover.jpg"
            random_name = random_str(10)

            BluetoothAmpWeb.B3.upload(random_name, cover_path, 50)

            {:ok, album} = Music.create_album(artist, %{name: name, cover: random_name})
            Enum.map(songs, fn song -> Music.create_song(album, song) end)

          end
        )
      end
    )
  end

end
