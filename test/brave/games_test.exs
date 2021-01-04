defmodule Brave.GamesTest do
  use Brave.DataCase

  alias Brave.Games
  alias Brave.Users

  describe "games" do
    alias Brave.Games.Game

    def fixture(:p1) do
      {:ok, user} = Users.create_user(%{"username" => "p1", "password" => "password"})
      user
    end

    def fixture(:p2) do
      {:ok, user} = Users.create_user(%{"username" => "p2", "password" => "password"})
      user
    end

    def fixture(:p3) do
      {:ok, user} = Users.create_user(%{"username" => "p3", "password" => "password"})
      user
    end

    def game_fixture(p1, p2, attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(%{p1_uuid: p1.uuid, p2_uuid: p2.uuid, p1_name: p1.username, p2_name: p2.username})
        |> Games.create_game()

      game
    end

    test "list_games/1 and list_completed_games/1 return all games in progress and completed respectively" do
      p1 = fixture(:p1)
      p2 = fixture(:p2)
      p3 = fixture(:p3)

      game = game_fixture(p1,p2)
      game2 = game_fixture(p1, p2, %{completed?: true})

      game3 = game_fixture(p3, p2)
      game4 = game_fixture(p1, p3, %{completed?: true})

      assert Games.list_games(%{"user" => p1.uuid}) == {:ok, [game]}
      assert Games.list_games(%{"user" => p2.uuid}) == {:ok, [game, game3]}
      assert Games.list_games(%{"user" => p2.uuid, "opponent" => p3.username}) == {:ok, [game3]}
      assert Games.list_games(%{"user" => p1.uuid, "opponent" => p3.username}) == {:ok, []}

      assert Games.list_completed_games(%{"user" => p1.uuid}) == {:ok, [game2, game4]}
      assert Games.list_completed_games(%{"user" => p3.uuid, "opponent" => p1.username}) == {:ok, [game4]}
      assert Games.list_completed_games(%{"user" => p2.uuid, "opponent" => p3.username}) == {:ok, []}
    end

    test "list_games/1 and list_completed_games/1 return errors with invalid inputs" do
      assert %{errors: %{"user" => ["required field"]}} = Games.list_games(%{})
      assert %{errors: %{"user" => ["required field"]}} = Games.list_completed_games(%{})
    end


    test "create_game/1 with valid data creates a game" do
      p1 = fixture(:p1)
      p2 = fixture(:p2)
      game_params = %{p1_uuid: p1.uuid, p2_uuid: p2.uuid, p1_name: p1.username, p2_name: p2.username}
      assert {:ok, %Game{} = game} = Games.create_game(game_params)
      assert game.completed? == false
      assert game.on_hold == []
      assert game.p1_card == nil
      assert game.p1_cards == [0,1,2,3,4,5,6,7]
      assert game.p1_general? == false
      assert game.p1_name == p1.username
      assert game.p1_points == 0
      assert game.p1_uuid == p1.uuid
      assert game.p1_winnings == []
      assert game.p2_card == nil
      assert game.p2_cards == [0,1,2,3,4,5,6,7]
      assert game.p2_general? == false
      assert game.p2_name == p2.username
      assert game.p2_points == 0
      assert game.p2_uuid == p2.uuid
      assert game.p2_winnings == []
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_game(%{})
    end

    test "update_game/1 placeholder test" do
      p1 = fixture(:p1)
      p2 = fixture(:p2)

      game = game_fixture(p1, p2, %{})
      update_params = %{"id" => game.game_id, "user" => p1.uuid, "card" => 1}
      assert %{errors: %{"good job" => ["not implemented yet"]}} = Games.update_game(update_params)
    end

    test "update_game/2 with invalid input returns error" do
      assert %{errors: %{"card" => ["required field"]}} = Games.update_game(%{"id" => "game uuid", "user" => "user uuid"})
      assert %{errors: %{"user" => ["required field"]}} = Games.update_game(%{"id" => "game uuid", "card" => 1})
      assert %{errors: %{"id" => ["required field"]}} = Games.update_game(%{"user" => "user uuid", "card" => 1})
      assert %{errors: %{"id" => ["required field"], "card" => ["required field"]}} = Games.update_game(%{"user" => "user id"})
      assert %{errors: %{"id" => ["required field"],"user" => ["required field"], "card" => ["required field"]}} = Games.update_game(%{})
    end

    test "get_game/1 returns the game when there is valid input" do
      p1 = fixture(:p1)
      p2 = fixture(:p2)
      game = game_fixture(p1, p2, %{})

      assert Games.get_game(%{"id" => game.game_id}) == {:ok, game}
    end

    test "get_game/1 returns error with invalid input" do
      assert %{errors: %{"id" => ["required field"]}} = Games.get_game(%{})
      assert %{errors: %{"id" => ["invalid game id"]}} = Games.get_game(%{"id" => "invalid game uuid"})
    end
  end
end
