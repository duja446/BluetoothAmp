defmodule Player.Server do
  use GenServer
  require Logger
  alias Phoenix.PubSub

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: PlayerServer)
  end

  defp connect() do
    :gen_tcp.connect(Application.get_env(:player, :mpd_ip), Application.get_env(:player, :mpd_port), [:binary, active: true, keepalive: true])
  end

  def init({pubsub, channel}) do
    PubSub.subscribe(pubsub, channel)
    port = 
      case connect() do
        {:ok, port} -> port
        {:error, _reason} -> :error
      end
    {:ok, %{
      pubsub: pubsub,
      channel: channel,
      port: port,
      current_song: nil,
      playing?: false
    }}
  end

  def get_current_song() do
    GenServer.call(PlayerServer, :get_current_song)
  end

  def get_playing?() do
    GenServer.call(PlayerServer, :get_playing?)
  end

  def play_song(song) do
    GenServer.cast(PlayerServer, {:play, song})
  end

  def continue() do
    GenServer.cast(PlayerServer, :continue)
  end

  def pause() do
    GenServer.cast(PlayerServer, :pause)
  end

  def handle_call(:get_current_song, _calller, %{current_song: current_song} = state) do
    {:reply, current_song, state}
  end

  def handle_call(:get_playing?, _calller, %{playing?: playing?} = state) do
    {:reply, playing?, state}
  end

  def handle_cast({:play, song}, %{port: port, pubsub: pubsub, channel: channel} = state) do
    Port.command(port, "clear\n")
    Port.command(port, "add \"#{rel_path song.path}\"\n")
    Port.command(port, "play 0\n")
    Phoenix.PubSub.broadcast(pubsub, channel, {:current_song, song})
    {:noreply, %{state | current_song: song, playing?: true}}
  end

  def handle_cast(:continue, %{port: port} = state) do
    Port.command(port, "pause 0\n")
    {:noreply, %{state | playing?: true}}
  end

  def handle_cast(:pause, %{port: port} = state) do
    Port.command(port, "pause 1\n")
    {:noreply, %{state | playing?: false}}
  end

  def handle_info(_, %{port: :error} = state) do
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
