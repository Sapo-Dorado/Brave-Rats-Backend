defmodule Brave.Games do

  import Ecto.Query, warn: false
  alias Brave.Repo

  alias Brave.Games.Game

  @default_hand [0,1,2,3,4,5,6,7]

  def list_games(params) do
    list_games_helper(params, false)
  end

  def list_completed_games(params) do
    list_games_helper(params, true)
  end

  def create_game(params) do
    params =
      params
      |> Map.put(:game_id, Ecto.UUID.generate)
      |> Map.put(:on_hold, [])
      |> Map.put(:p1_cards, @default_hand)
      |> Map.put(:p2_cards, @default_hand)
      |> Map.put(:p1_winnings, [])
      |> Map.put(:p2_winnings, [])

    %Game{}
    |> Game.changeset(params)
    |> Repo.insert()
  end

  def get_game(%{"id" => game_id}) do
    query =
      from g in Game,
        where: g.game_id == ^game_id
    case Repo.one(query) do
      nil ->
        %{errors: %{"game_id" => ["invalid game id"]}}
      game ->
        {:ok, game}
    end
  end

  def get_game(_) do
    %{errors: %{"id" => ["required field"]}}
  end

  def update_game(%{"id" => game_id, "user" => user_id, "card" => card})do
    %{errors: %{"good job" => ["not implemented yet"]}}
  end

  def update_game(params) do
    Brave.find_missing_params(params,["id","user","card"])
  end

  defp list_games_helper(%{"user" => user_id, "opponent" => opponent_name}, completed?) do
    query =
      from g in Game,
        where: ((g.p1_uuid == ^user_id and g.p2_name == ^opponent_name) or
          (g.p2_uuid == ^user_id and g.p2_name == ^opponent_name)) and (g.completed? == ^completed?)
    {:ok, Repo.all(query)}
  end

  defp list_games_helper(%{"user" => user_id}, completed?) do
    query =
      from g in Game,
        where: (g.p1_uuid == ^user_id or g.p2_uuid == ^user_id) and (g.completed? == ^completed?)
    {:ok, Repo.all(query)}
  end

  defp list_games_helper(_params,_completed?) do
    %{errors: %{"user" => ["required field"]}}
  end

end
