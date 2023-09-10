defmodule Player.Server do
  use GenServer
  require Logger
  alias Phoenix.PubSub

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: PlayerServer)
  end

  defp connect() do
    _ = :gen_tcp.connect(Application.get_env(:player, :mpd_ip), Application.get_env(:player, :mpd_port), [:binary, active: true, keepalive: true])
  end

  def init({pubsub, channel}) do
    {:ok, port} = connect()
    PubSub.subscribe(pubsub, channel)
    {:ok, %{port: port}}
  end

  def handle_info(%{event: "current_song", payload: song}, %{port: p} = state) do
    if song != nil do
      Port.command(p, "clear\n")
      Port.command(p, "add \"#{rel_path song.path}\"\n")
      Port.command(p, "play 0\n")
    end
    {:noreply, state}
  end

  def handle_info(%{event: "continue_pause", payload: s}, %{port: p} = state) do 
    Port.command(p, "pause #{if s, do: 0, else: 1}\n")
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state) do
    {:ok, port} = connect()
    {:noreply, %{state | port: port}}
  end

  def handle_info(info, state) do
    Logger.debug(inspect info)
    {:noreply, state}
  end

  defp rel_path(path) do
    Path.relative_to(path, Path.expand("~/Music"))
  end
end
