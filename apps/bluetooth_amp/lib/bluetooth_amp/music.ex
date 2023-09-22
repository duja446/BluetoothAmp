defmodule BluetoothAmp.Music do
  @moduledoc """
  The Music context.
  """

  import Ecto.Query, warn: false
  alias BluetoothAmp.Repo

  alias BluetoothAmp.Music.Artist
  alias BluetoothAmp.Music.Album
  alias BluetoothAmp.Music.Song

  # ARTIST

  def list_artists do
    Repo.all(Artist)
  end

  def get_artist_with_albums!(id) do
    Repo.get(Artist, id) |> Repo.preload(:albums)
  end

  def create_artist(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
    |> Repo.insert()
  end


  # ALBUM

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

  def get_number_of_songs(id) do
    query = from a in Album,
      where: a.id == ^id,
      join: s in Song,
      on:   a.id  == s.album_id,
      select: count(s.album_id)
    Repo.one!(query)
  end


  # SONG

  def list_songs do
    Repo.all(Song)
  end

  def list_liked_songs do
    Song
    |> where([song], song.liked == true)
    |> Repo.all()
  end

  def list_songs_with_album do
    Song
    |> join(:left, [song], album in assoc(song, :album))
    |> order_by([asc: :name])
    |> preload(:album)
    |> Repo.all()
  end

  def get_songs_with_album(list_of_ids) do
    Song
    |> where([song], song.id in ^list_of_ids)
    |> preload(:album)
    |> select([song], {song.id, song})
    |> Repo.all()
  end

  def get_song!(id), do: Repo.get!(Song, id)

  def full_song_query(q) do
    q
    |> join(:left, [song], album in assoc(song, :album))
    |> join(:left, [song, album], artist in assoc(album, :artist))
    |> preload([song, album, artist], [album: {album, artist: artist}])
  end

  def get_song_full!(id) do
    Song
    |> where([song], song.id == ^id)
    |> full_song_query()
    |> Repo.one!()
  end

  def get_song_with_album!(id), do: Repo.get(Song, id) |> Repo.preload(:album)

  def get_next_song!(%Song{track: track, album_id: album_id}) do
    number_of_songs = get_number_of_songs(album_id)
    new_track_number = if track + 1 > number_of_songs, do: 1, else: track + 1
    get_song_from_album_with_track_number(new_track_number, album_id)
  end

  def get_previous_song!(%Song{track: track, album_id: album_id}) do
    number_of_songs = get_number_of_songs(album_id)
    new_track_number = if track == 1, do: number_of_songs, else: track - 1
    get_song_from_album_with_track_number(new_track_number, album_id)
  end

  defp get_song_from_album_with_track_number(new_track_number, album_id) do
    Song
    |> where([song], song.album_id == ^album_id)
    |> where([song], song.track == ^new_track_number)
    |> full_song_query()
    |> Repo.one!()
    
  end

  def like_song(id) do
    song = Repo.get!(Song, id) 
    Song.changeset(song, %{liked: ! song.liked})
    |> Repo.update()
  end

  def create_song(%Album{} = a, attrs \\ %{}) do
    %Song{}
    |> Song.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:album, a)
    |> Repo.insert()
  end
end
