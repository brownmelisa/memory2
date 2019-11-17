defmodule Memory2Web.GamesChannel do
  use Memory2Web, :channel

  alias Memory2.Game
  alias Memory2.BackupAgent
  alias Memory2.GameServer

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      game = GameServer.peek(name)
      BackupAgent.put(name, game)
      socket = socket
               |> assign(:name, name)
      {:ok, %{ "join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("check_match", %{"index1" => ii}, socket ) do
    name = socket.assigns[:name]
    game = GameServer.check_match(name, ii)
    broadcast!(socket, "update", %{ "game" => Game.client_view(game) })
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

end
