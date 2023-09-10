defmodule BluetoothAmp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BluetoothAmp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BluetoothAmp.PubSub}
      # Start a worker by calling: BluetoothAmp.Worker.start_link(arg)
      # {BluetoothAmp.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BluetoothAmp.Supervisor)
  end
end
