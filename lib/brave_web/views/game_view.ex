defmodule BraveWeb.GameView do
  use BraveWeb, :view
  alias BraveWeb.GameView

  def render("index.json", %{games: games, uuid: uuid}) do
    %{data: render_many(games, GameView, "game.json", uuid: uuid)}
  end

  def render("show.json", %{game: game, uuid: uuid}) do
    %{data: render_one(game, GameView, "game.json", uuid: uuid)}
  end

  def render("game.json", %{game: game, uuid: uuid}) do
    result = %{game_id: game.game_id,
      p1_name: game.p1_name,
      p2_name: game.p2_name,
      p1_card: game.p1_card != nil,
      p2_card: game.p2_card != nil,
      p1_points: game.p1_points,
      p2_points: game.p2_points,
      p1_winnings: game.p1_winnings,
      p2_winnings: game.p2_winnings,
      p1_cards: game.p1_cards,
      p2_cards: game.p2_cards,
      on_hold: game.on_hold,
      p1_general?: game.p1_general?,
      p2_general?: game.p2_general?,
      p1_spy?: game.p1_spy?,
      p2_spy?: game.p2_spy?,
      completed?: game.completed?
    }
    cond do
      uuid == game.p1_uuid or game.p2_spy? ->
        result
        |> Map.put(:p1_card, game.p1_card)
      uuid == game.p2_uuid or game.p1_spy?->
        result
        |> Map.put(:p2_card, game.p2_card)
      true -> result
    end
  end
end
