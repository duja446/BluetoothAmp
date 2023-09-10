defmodule BluetoothAmp.Music.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :last_played, :naive_datetime
    field :name, :string
    field :played_times, :integer
    field :track, :integer
    field :duration, :integer
    field :path, :string
    belongs_to :album, BluetoothAmp.Music.Album

    timestamps()
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:name, :track, :played_times, :last_played, :duration, :path])
    |> validate_required([:name, :track, :duration, :path])
  end
end
