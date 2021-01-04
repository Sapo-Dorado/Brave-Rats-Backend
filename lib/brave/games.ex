defmodule Brave.Games do

  import Ecto.Query, warn: false
  alias Brave.Repo

  alias Brave.Games.Game

  @player1 0
  @player2 1

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
        %{errors: %{"id" => ["invalid game id"]}}
      game ->
        {:ok, game}
    end
  end

  def get_game(_) do
    %{errors: %{"id" => ["required field"]}}
  end

  def update_game(%{"id" => game_id, "user" => user_id, "card" => card_string})do
    with {:ok, %Game{} = game} <- get_game(%{"id" => game_id}),
         card <- String.to_integer(card_string) do
      cond do
        game.completed? -> %{errors: %{"id" => ["game is over"]}}
        game.p1_uuid == user_id ->
          cond do
            game.p1_card != nil -> %{errors: %{"card" => ["not your turn"]}}
            card in game.p1_cards ->
                {:ok, game} =
                  game
                  |> Game.changeset(%{p1_card: card, p1_cards: List.delete(game.p1_cards, card)})
                  |> Repo.update()
                process_turn(game)
            true -> %{errors: %{"card" => ["invalid card:" <> card_string]}}
          end
        game.p2_uuid == user_id ->
          cond do
            game.p2_card != nil -> %{errors: %{"card" => ["not your turn"]}}
            card in game.p2_cards ->
              {:ok, game} =
                game
                |> Game.changeset(%{p2_card: card, p2_cards: List.delete(game.p2_cards, card)})
                |> Repo.update()
              process_turn(game)
            true -> %{errors: %{"card" => ["invalid card:" <> to_string(card)]}}
          end
        true -> %{errors: %{"user" => ["unauthorized uuid"]}}
      end
    end
  end

  def update_game(params) do
    Brave.find_missing_params(params,["id","user","card"])
  end

  defp list_games_helper(%{"user" => user_id, "opponent" => opponent_name}, completed?) do
    query =
      from g in Game,
        where: ((g.p1_uuid == ^user_id and g.p2_name == ^opponent_name) or
          (g.p2_uuid == ^user_id and g.p1_name == ^opponent_name)) and (g.completed? == ^completed?)
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

  defp process_turn(game) do
    if(game.p1_card == nil or game.p2_card == nil) do
      {:ok, game}
    else
      params =
        %{p1_card: nil, p2_card: nil}
        |> process_combat(game)
        |> Enum.into(get_state_vars(game))
      game
      |> Game.changeset(params)
      |> Repo.update()
    end
  end

  defp get_state_vars(game) do
    vars = %{
      p1_spy?: game.p1_card == 2 and game.p2_card != 5 and game.p2_card != 0,
      p2_spy?: game.p2_card == 2 and game.p1_card != 5 and game.p1_card != 0,
      p1_general?: game.p1_card == 6 and game.p2_card != 5 and game.p2_card != 0,
      p2_general?: game.p2_card == 6 and game.p1_card != 5 and game.p1_card != 0
    }
    if game.p1_cards == [], do: vars |> Map.put(:completed?, true), else: vars
  end

  defp process_combat(params, game) do
    c1 = game.p1_card
    c2 = game.p2_card
    cond do
      c1 == 5 or c2 == 5 -> params |> process_power_winner(game)
      c1 == 0 or c2 == 0 -> params |> on_hold(game)
      c1 == c2 -> params |> process_power_winner(game)
      c1 == 7 ->
        if(c2 == 1) do
          params
          |> process_round_win(game, @player2)
          |> Map.put(:completed?, true)
          |> Map.put(:p2_points, 10)
          |> Map.put(:p1_points, 0)
        else
          params |> process_round_win(game, @player1)
        end
      c2 == 7 ->
        if(c1 == 1) do
          params
          |> process_round_win(game, @player1)
          |> Map.put(:completed?, true)
          |> Map.put(:p1_points, 10)
          |> Map.put(:p2_points, 0)
        else
          params |> process_round_win(game, @player2)
        end
      true -> params |> process_power_winner(game)
    end
  end

  defp on_hold(params, game) do
    params |> Map.put(:on_hold, [[game.p1_card, game.p2_card] | game.on_hold])
  end

  defp process_round_win(params, game, player) do
    winnings = [[game.p1_card, game.p2_card] | game.on_hold]
    {points_field, points, winnings_field, winnings} =
      if player == @player1 do
        {:p1_points, game.p1_points + 1, :p1_winnings, winnings ++ game.p1_winnings}
      else
        {:p2_points, game.p2_points + 1, :p2_winnings, winnings ++ game.p2_winnings}
      end
    winning_cards =
      for cards <- game.on_hold do
        [p1 | [p2 | []]] = cards
        if player == @player1, do: p1, else: p2
      end
    params =
      params
      |> Map.put(:on_hold, [])
      |> Map.put(winnings_field, winnings)
      |> Map.put(points_field, Enum.reduce(winning_cards, points, fn(card, pnts) ->
        if card == 4, do: pnts + 2, else: pnts + 1
      end))
    if (params[points_field] >= 4) do
      params |> Map.put(:completed?, true)
    else
      params
    end
  end

  defp process_power_winner(params, game) do
    p1_power = if game.p1_general?, do: game.p1_card + 2, else: game.p1_card
    p2_power = if game.p2_general?, do: game.p2_card + 2, else: game.p2_card
    if(p1_power == p2_power) do
      params |> on_hold(game)
    else
      winner =
        if(assassin_effect?(game)) do
          if p1_power < p2_power, do: @player1, else: @player2
        else
          if p1_power > p2_power, do: @player1, else: @player2
        end
      params |> process_round_win(game, winner)
    end
  end

  def assassin_effect?(game) do
    (game.p1_card == 3 and game.p2_card != 5) or (game.p2_card == 3 and game.p1_card != 5)
  end
end
