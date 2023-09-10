defmodule BluetoothAmpWeb.PlayerState do
  use GenServer
  alias BluetoothAmp.Music

  @name __MODULE__
  @topic "player_state"
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def init(_) do
    BluetoothAmpWeb.Endpoint.subscribe(@topic)
    :ets.new(:player_state, [:set, :named_table])
    :ets.insert(:player_state, {:current_song, nil})
    :ets.insert(:player_state, {:playing, false})
    {:ok, :ok}
  end

  def add_current_song(%Music.Song{} = song) do
    GenServer.cast(@name, {:insert, {:current_song, song}})
    BluetoothAmpWeb.Endpoint.broadcast(@topic, "current_song", song)
  end

  def get_current_song() do
    [{:current_song, song}] = :ets.lookup(:player_state, :current_song)
    song
  end

  def get_playing() do
    [{:playing, playing}] = :ets.lookup(:player_state, :playing)
    playing
  end

  def remove_current_song() do
    GenServer.cast(@name, {:insert, {:current_song, nil}})
    BluetoothAmpWeb.Endpoint.broadcast(@topic, "current_song", nil)
  end

  def play(%Music.Song{} = song) do
    add_current_song(song) 
    GenServer.cast(@name, {:insert, {:playing, true}})
  end

  def continue() do
    GenServer.cast(@name, {:insert, {:playing, true}})
    BluetoothAmpWeb.Endpoint.broadcast(@topic, "continue_pause", true)
  end

  def pause() do
    GenServer.cast(@name, {:insert, {:playing, false}})
    BluetoothAmpWeb.Endpoint.broadcast(@topic, "continue_pause", false)
  end

  def handle_cast({:insert, data}, _state) do
    :ets.insert(:player_state, data)
    {:noreply, :ok}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

    
end
