defmodule BluetoothAmp.Music.Album do
  use Ecto.Schema
  import Ecto.Changeset

  schema "albums" do
    field :name, :string
    field :year_of_release, :integer
    field :cover, :string
    has_many :songs, BluetoothAmp.Music.Song
    belongs_to :artist, BluetoothAmp.Music.Artist

    timestamps()
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:name, :year_of_release, :cover])
    |> validate_required([:name, :cover])
  end
end
