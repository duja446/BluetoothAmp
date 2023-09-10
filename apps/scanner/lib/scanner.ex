defmodule Scanner do

  def scan(dir) do
    dir
    |> ls_r()
    |> Enum.map(&Scanner.Parser.Flac.parse/1)
    |> Enum.reduce(%{}, &make/2)
    
  end

  def format(%{
    file_info: %{path: path},
    stream_info: %{duration: duration}, 
    vorbis_comment: %{album: album, artist: artist, title: title, tracknumber: track}
    }) do

    {artist, %{name: album, path: Path.dirname(path)}, %{name: title, track: track, duration: duration, path: path}}
  end

  def make(song_metadata, acc) do
    {artist, album, song} = format(song_metadata) 
    Map.update(acc, artist, %{album => [song]}, fn val -> Map.update(val, album, [song], fn val -> [song | val] end) end)
  end

  def ls_r(path \\ ".") do
    cond do
      File.regular?(path) and check_extension(path) -> [path]
      File.dir?(path) ->
        File.ls!(path)
        |> Enum.map(&Path.join(path, &1))
        |> Enum.map(&ls_r/1)
        |> Enum.concat
      true -> []
    end
  end

  def check_extension(file) do
    String.ends_with?(file, [".flac"])
  end
end

