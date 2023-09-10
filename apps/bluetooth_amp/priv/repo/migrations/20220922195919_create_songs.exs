defmodule BluetoothAmp.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :name, :string
      add :track, :integer
      add :played_times, :integer
      add :last_played, :naive_datetime
      add :duration, :integer
      add :path, :string
      add :album_id, references(:albums, on_delete: :nothing)

      timestamps()
    end

    create index(:songs, [:album_id])
  end
end
