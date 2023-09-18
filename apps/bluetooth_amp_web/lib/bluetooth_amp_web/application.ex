defmodule BluetoothAmpWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BluetoothAmpWeb.Telemetry,
      # Start the Endpoint (http/https)
      BluetoothAmpWeb.Endpoint,
      # Start a worker by calling: BluetoothAmpWeb.Worker.start_link(arg)
      # {BluetoothAmpWeb.Worker, arg}
      {Player.Server, {BluetoothAmp.PubSub, "player_state"}},
      #{Bluetoothctl.Server, {BluetoothAmp.PubSub, "bluetoothctl"}},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BluetoothAmpWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BluetoothAmpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
