defmodule BluetoothAmp.Repo.Migrations.AddLikes do
  use Ecto.Migration

  def change do
    alter table(:songs) do
      add :liked, :boolean
    end
  end
end
