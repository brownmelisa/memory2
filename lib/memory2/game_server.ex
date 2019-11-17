defmodule Memory2.GameServer do
  use GenServer

  def reg(name) do
    {:via, Registry, {Memory2.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    Memory2.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = Memory2.BackupAgent.get(name) || Memory2.Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def init(game) do
    {:ok, game}
  end

  # handle check_match call from the browser
  def check_match(name, index1) do
    GenServer.call(reg(name), {:check_match, name, index1})
  end

  def handle_call({:check_match, name, index1}, _from, game) do
    game = Memory2.Game.check_match(game, index1)
    Memory2.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  # handle peek call
  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end

end
