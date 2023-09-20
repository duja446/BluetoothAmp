defmodule BluetoothAmp.Scan do
  alias BluetoothAmp.Repo
  alias BluetoothAmp.Music
  require Logger

  def random_str(len) do
    for _ <- 1..len, into: "", do: <<Enum.random('0123456789adbcdef')>>
  end

  def extract_waveform(song_path) do
    {data, _} = System.cmd("audiowaveform", ["-i", song_path, "--output-format", "dat", "--bits", "8", "--pixels-per-second", "100"])
    data
  end

  def run() do
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
            Logger.debug("sent cover: #{path <> "/Cover.jpg"}")
            cover_path = path <> "/Cover.jpg"
            random_name = random_str(10)
            Logger.debug("with name: #{random_name}")

            FileServer.upload(random_name, cover_path, 50)

            {:ok, album} = Music.create_album(artist, %{name: name, cover: random_name})
            Enum.map(songs, fn song -> 
              waveform = extract_waveform(song.path)
              Music.create_song(album, Map.put(song, :waveform, waveform)) 

            end)

          end
        )
      end
    )
  end
end
