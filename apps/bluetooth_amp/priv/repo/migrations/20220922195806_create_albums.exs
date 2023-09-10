defmodule BluetoothAmp.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :name, :string
      add :year_of_release, :integer
      add :cover, :string
      add :artist_id, references(:artists, on_delete: :nothing)

      timestamps()
    end

    create index(:albums, [:artist_id])
  end
end
