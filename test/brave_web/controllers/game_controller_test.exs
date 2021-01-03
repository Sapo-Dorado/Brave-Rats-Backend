defmodule BraveWeb.GameControllerTest do
  use BraveWeb.ConnCase

  alias Brave.Games
  alias Brave.Games.Game

  @create_attrs %{
    completed: true,
    game_id: "some game_id",
    on_hold: [],
    p1_card: 42,
    p1_cards: [],
    p1_general?: true,
    p1_name: "some p1_name",
    p1_points: 42,
    p1_uuid: "some p1_uuid",
    p1_winnings: [],
    p2_card: 42,
    p2_cards: [],
    p2_general?: true,
    p2_name: "some p2_name",
    p2_points: 42,
    p2_uuid: "some p2_uuid",
    p2_winnings: []
  }
  @update_attrs %{
    completed: false,
    game_id: "some updated game_id",
    on_hold: [],
    p1_card: 43,
    p1_cards: [],
    p1_general?: false,
    p1_name: "some updated p1_name",
    p1_points: 43,
    p1_uuid: "some updated p1_uuid",
    p1_winnings: [],
    p2_card: 43,
    p2_cards: [],
    p2_general?: false,
    p2_name: "some updated p2_name",
    p2_points: 43,
    p2_uuid: "some updated p2_uuid",
    p2_winnings: []
  }
  @invalid_attrs %{completed: nil, game_id: nil, on_hold: nil, p1_card: nil, p1_cards: nil, p1_general?: nil, p1_name: nil, p1_points: nil, p1_uuid: nil, p1_winnings: nil, p2_card: nil, p2_cards: nil, p2_general?: nil, p2_name: nil, p2_points: nil, p2_uuid: nil, p2_winnings: nil}

  def fixture(:game) do
    {:ok, game} = Games.create_game(@create_attrs)
    game
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all games", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create game" do
    test "renders game when data is valid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.game_path(conn, :show, id))

      assert %{
               "id" => id,
               "completed" => true,
               "game_id" => "some game_id",
               "on_hold" => [],
               "p1_card" => 42,
               "p1_cards" => [],
               "p1_general?" => true,
               "p1_name" => "some p1_name",
               "p1_points" => 42,
               "p1_uuid" => "some p1_uuid",
               "p1_winnings" => [],
               "p2_card" => 42,
               "p2_cards" => [],
               "p2_general?" => true,
               "p2_name" => "some p2_name",
               "p2_points" => 42,
               "p2_uuid" => "some p2_uuid",
               "p2_winnings" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), game: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update game" do
    setup [:create_game]

    test "renders game when data is valid", %{conn: conn, game: %Game{id: id} = game} do
      conn = put(conn, Routes.game_path(conn, :update, game), game: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.game_path(conn, :show, id))

      assert %{
               "id" => id,
               "completed" => false,
               "game_id" => "some updated game_id",
               "on_hold" => [],
               "p1_card" => 43,
               "p1_cards" => [],
               "p1_general?" => false,
               "p1_name" => "some updated p1_name",
               "p1_points" => 43,
               "p1_uuid" => "some updated p1_uuid",
               "p1_winnings" => [],
               "p2_card" => 43,
               "p2_cards" => [],
               "p2_general?" => false,
               "p2_name" => "some updated p2_name",
               "p2_points" => 43,
               "p2_uuid" => "some updated p2_uuid",
               "p2_winnings" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, game: game} do
      conn = put(conn, Routes.game_path(conn, :update, game), game: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete game" do
    setup [:create_game]

    test "deletes chosen game", %{conn: conn, game: game} do
      conn = delete(conn, Routes.game_path(conn, :delete, game))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.game_path(conn, :show, game))
      end
    end
  end

  defp create_game(_) do
    game = fixture(:game)
    %{game: game}
  end
end
