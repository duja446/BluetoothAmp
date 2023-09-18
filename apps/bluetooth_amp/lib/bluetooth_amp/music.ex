defmodule BluetoothAmp.Music do
  @moduledoc """
  The Music context.
  """

  import Ecto.Query, warn: false
  alias BluetoothAmp.Repo

  alias BluetoothAmp.Music.Artist
  alias BluetoothAmp.Music.Song

  def list_artists do
    Repo.all(Artist)
  end

  def get_artist_by_name!(name) do
    Repo.get_by!(Artist, name: name)
  end


  def create_artist(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
    |> Repo.insert()
  end

  def update_artist(%Artist{} = artist, attrs) do
    artist
    |> Artist.changeset(attrs)
    |> Repo.update()
  end

  def delete_artist(%Artist{} = artist) do
    Repo.delete(artist)
  end

  def change_artist(%Artist{} = artist, attrs \\ %{}) do
    Artist.changeset(artist, attrs)
  end

  alias BluetoothAmp.Music.Album

  def list_albums do
    Repo.all(Album)
  end

  def get_album!(id), do: Repo.get!(Album, id)

  def get_album_full!(id) do
    song_query = from s in Song, order_by: s.track
    Repo.get!(Album, id) 
    |> Repo.preload(songs: song_query)
    |> Repo.preload(:artist)
  end

  def create_album(%Artist{} =  a, attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:artist, a)
    |> Repo.insert()
  end

  def update_album(%Album{} = album, attrs) do
    album
    |> Album.changeset(attrs)
    |> Repo.update()
  end

  def delete_album(%Album{} = album) do
    Repo.delete(album)
  end

  def change_album(%Album{} = album, attrs \\ %{}) do
    Album.changeset(album, attrs)
  end


  def list_songs do
    Repo.all(Song)
  end

  def list_songs_with_album do
    Song
    |> join(:left, [song], album in assoc(song, :album))
    |> order_by([asc: :name])
    |> preload(:album)
    |> Repo.all()
  end

  def get_song!(id), do: Repo.get!(Song, id)

  def get_song_full!(id) do
    Song
    |> where([song], song.id == ^id)
    |> join(:left, [song], album in assoc(song, :album))
    |> join(:left, [song, album], artist in assoc(album, :artist))
    |> preload([song, album, artist], [album: {album, artist: artist}])
    |> Repo.one!()
  end

  def get_song_with_album!(id), do: Repo.get(Song, id) |> Repo.preload(:album)

  def get_album_name(%Song{} = song) do
    query = from s in Song,
      join: a in Album, 
      on:   a.id  == s.album_id,
      select: a.name,
      where: s.id == ^song.id
    Repo.one!(query)
  end

  def create_song(%Album{} = a, attrs \\ %{}) do
    %Song{}
    |> Song.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:album, a)
    |> Repo.insert()
  end

  def create_temp_song(name) do
    %Song{name: name, duration: 0}
  end

  def update_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
  end

  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end
end
