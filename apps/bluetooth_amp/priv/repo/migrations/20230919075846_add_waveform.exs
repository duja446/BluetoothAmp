defmodule BluetoothAmp.Repo.Migrations.AddWaveform do
  use Ecto.Migration

  def change do
    alter table(:songs) do
      add :waveform, :binary
    end
    
  end
end
