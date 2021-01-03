defmodule BraveWeb.GameView do
  use BraveWeb, :view
  alias BraveWeb.GameView

  def render("index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game.json")}
  end

  def render("show.json", %{game: game}) do
    %{data: render_one(game, GameView, "game.json")}
  end

  def render("game.json", %{game: game}) do
    %{game_id: game.game_id,
      p1_uuid: game.p1_uuid,
      p2_uuid: game.p2_uuid,
      p1_name: game.p1_name,
      p2_name: game.p2_name,
      p1_card: game.p1_card,
      p2_card: game.p2_card,
      p1_points: game.p1_points,
      p2_points: game.p2_points,
      p1_winnings: game.p1_winnings,
      p2_winnings: game.p2_winnings,
      p1_cards: game.p1_cards,
      p2_cards: game.p2_cards,
      on_hold: game.on_hold,
      p1_general?: game.p1_general?,
      p2_general?: game.p2_general?,
      completed?: game.completed?}
  end
end
