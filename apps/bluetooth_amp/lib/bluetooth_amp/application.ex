defmodule BluetoothAmp.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BluetoothAmp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BluetoothAmp.PubSub}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BluetoothAmp.Supervisor)
  end
end
