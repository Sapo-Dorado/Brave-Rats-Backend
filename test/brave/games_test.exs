defmodule Brave.GamesTest do
  use Brave.DataCase

  alias Brave.Games

  describe "games" do
    alias Brave.Games.Game

    @valid_attrs %{completed: true, game_id: "some game_id", on_hold: [], p1_card: 42, p1_cards: [], p1_general?: true, p1_name: "some p1_name", p1_points: 42, p1_uuid: "some p1_uuid", p1_winnings: [], p2_card: 42, p2_cards: [], p2_general?: true, p2_name: "some p2_name", p2_points: 42, p2_uuid: "some p2_uuid", p2_winnings: []}
    @update_attrs %{completed: false, game_id: "some updated game_id", on_hold: [], p1_card: 43, p1_cards: [], p1_general?: false, p1_name: "some updated p1_name", p1_points: 43, p1_uuid: "some updated p1_uuid", p1_winnings: [], p2_card: 43, p2_cards: [], p2_general?: false, p2_name: "some updated p2_name", p2_points: 43, p2_uuid: "some updated p2_uuid", p2_winnings: []}
    @invalid_attrs %{completed: nil, game_id: nil, on_hold: nil, p1_card: nil, p1_cards: nil, p1_general?: nil, p1_name: nil, p1_points: nil, p1_uuid: nil, p1_winnings: nil, p2_card: nil, p2_cards: nil, p2_general?: nil, p2_name: nil, p2_points: nil, p2_uuid: nil, p2_winnings: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Games.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Games.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Games.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Games.create_game(@valid_attrs)
      assert game.completed == true
      assert game.game_id == "some game_id"
      assert game.on_hold == []
      assert game.p1_card == 42
      assert game.p1_cards == []
      assert game.p1_general? == true
      assert game.p1_name == "some p1_name"
      assert game.p1_points == 42
      assert game.p1_uuid == "some p1_uuid"
      assert game.p1_winnings == []
      assert game.p2_card == 42
      assert game.p2_cards == []
      assert game.p2_general? == true
      assert game.p2_name == "some p2_name"
      assert game.p2_points == 42
      assert game.p2_uuid == "some p2_uuid"
      assert game.p2_winnings == []
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, %Game{} = game} = Games.update_game(game, @update_attrs)
      assert game.completed == false
      assert game.game_id == "some updated game_id"
      assert game.on_hold == []
      assert game.p1_card == 43
      assert game.p1_cards == []
      assert game.p1_general? == false
      assert game.p1_name == "some updated p1_name"
      assert game.p1_points == 43
      assert game.p1_uuid == "some updated p1_uuid"
      assert game.p1_winnings == []
      assert game.p2_card == 43
      assert game.p2_cards == []
      assert game.p2_general? == false
      assert game.p2_name == "some updated p2_name"
      assert game.p2_points == 43
      assert game.p2_uuid == "some updated p2_uuid"
      assert game.p2_winnings == []
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_game(game, @invalid_attrs)
      assert game == Games.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end
end
