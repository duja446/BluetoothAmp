defmodule BluetoothAmp.Scan do
  alias BluetoothAmp.Repo
  alias BluetoothAmp.Music


  def run() do
    Repo.delete_all Music.Song  
    Repo.delete_all Music.Album  
    Repo.delete_all Music.Artist

    scanned = Scanner.scan(Path.expand("~/Music/"))

    Enum.map(scanned, 
      fn {artist_name, albums_map} -> 
        {:ok, artist} = Music.create_artist(%{name: artist_name})
        Enum.map(albums_map, 
          fn {album, songs} -> 
            {:ok, created_album} = create_album(album, artist)

            Enum.map(songs, fn song -> create_song(created_album, song) end)
          end)
      end)
  end

  defp random_str(len) do
    for _ <- 1..len, into: "", do: <<Enum.random('0123456789adbcdef')>>
  end

  defp create_album(%{name: name, path: path}, artist) do
    cover_path = path <> "/Cover.jpg"
    random_name = random_str(10)

    if File.exists?(cover_path), do: FileServer.upload(random_name, cover_path, 50)

    Music.create_album(artist, %{name: name, cover: random_name})
  end

  defp extract_waveform(song_path) do
    {data, _} = System.cmd("audiowaveform", ["-i", song_path, "--output-format", "dat", "--bits", "16", "--pixels-per-second", "100"])
    data
  end

  defp create_song(album, song) do
    waveform = extract_waveform(song.path)
    Music.create_song(album, Map.put(song, :waveform, waveform)) 
  end
end
