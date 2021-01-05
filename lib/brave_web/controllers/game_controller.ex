defmodule BraveWeb.GameController do
  use BraveWeb, :controller

  alias Brave.Users
  alias Brave.Users.User

  alias Brave.Games
  alias Brave.Games.Game

  action_fallback BraveWeb.FallbackController

  def index(conn, params) do
    with {:ok, games} <- Games.list_games(params) do
      render(conn, "index.json", games: games, uuid: params["user"])
    end
  end

  def index_completed(conn, params) do
    with {:ok, games} <- Games.list_completed_games(params) do
      render(conn, "index.json", games: games, uuid: params["user"])
    end
  end

  def create(conn, %{"user" => user_id, "opponent" => opponent_name}) do
    with {:ok, %User{} = p1} <- Users.get_user_by_uuid(user_id),
         {:ok, %User{} = p2} <- Users.get_user_by_username(opponent_name),
         game_params <- %{p1_uuid: p1.uuid, p1_name: p1.username, p2_uuid: p2.uuid, p2_name: p2.username},
         {:ok, %Game{} = game} <- Games.create_game(game_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.game_path(conn, :show, id: game.game_id))
      |> render("show.json", game: game, uuid: user_id)
    end
  end

  def create(_conn, params) do
    Brave.find_missing_params(params,["user", "opponent"])
  end

  def show(conn, params) do
    with {:ok, %Game{} = game} <- Games.get_game(params) do
      render(conn, "show.json", game: game, uuid: params["user"])
    end
  end

  def update(conn, params) do
    with {:ok, %Game{} = game} <- Games.update_game(params) do
      render(conn, "show.json", game: game, uuid: params["user"])
    end
  end
end
