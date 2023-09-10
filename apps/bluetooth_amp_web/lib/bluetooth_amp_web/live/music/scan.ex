defmodule BluetoothAmpWeb.Music.Scan do
  use BluetoothAmpWeb, :live_view
  require Logger

  alias BluetoothAmp.Repo
  alias BluetoothAmp.Music

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("scan", _, socket) do
    scan()
    {:noreply, socket}
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
            random_name = for _ <- 1..10, into: "", do: <<Enum.random('0123456789abdcef')>>
            BluetoothAmpWeb.B3.upload(random_name, cover_path, 50)

            {:ok, album} = Music.create_album(artist, %{name: name, cover: random_name})
            Enum.map(songs, fn song -> Music.create_song(album, song) end)

          end
        )
      end
    )
  end
 
end
