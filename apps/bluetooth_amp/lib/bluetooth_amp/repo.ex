defmodule BluetoothAmp.Repo do
  use Ecto.Repo,
    otp_app: :bluetooth_amp,
    adapter: Ecto.Adapters.SQLite3
end
