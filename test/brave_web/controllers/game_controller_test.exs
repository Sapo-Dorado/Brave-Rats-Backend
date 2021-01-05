defmodule BraveWeb.GameControllerTest do
  use BraveWeb.ConnCase

  alias Brave.Users

  alias Brave.Games
  alias Brave.Games.Game

  def fixture(:p1) do
    {:ok, user} = Users.create_user(%{"username" => "p1", "password" => "password"})
    user
  end

  def fixture(:p2) do
    {:ok, user} = Users.create_user(%{"username" => "p2", "password" => "password"})
    user
  end

  def fixture(:game) do
    p1 = fixture(:p1)
    p2 = fixture(:p2)
    {:ok, game} = Games.create_game(%{p1_uuid: p1.uuid, p1_name: p1.username, p2_uuid: p2.uuid, p2_name: p2.username})
    game
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all games when input is valid", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index, user: "uuid", opponent: "username"))
      assert json_response(conn, 200)["data"] == []

      conn = get(conn, Routes.game_path(conn, :index, user: "uuid"))
      assert json_response(conn, 200)["data"] == []
    end

    test "returns error when user is not specified", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index))
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "index completed" do
    test "lists all completed games when input is valid", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index_completed, user: "uuid", opponent: "username"))
      assert json_response(conn, 200)["data"] == []

      conn = get(conn, Routes.game_path(conn, :index_completed, user: "uuid"))
      assert json_response(conn, 200)["data"] == []
    end

    test "returns error when user is not specified", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :index_completed))
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "create game" do
    setup [:create_users]

    test "renders game when data is valid", %{conn: conn, p1: p1, p2: p2} do
      conn = post(conn, Routes.game_path(conn, :create, user: p1.uuid, opponent: p2.username))
      assert %{"game_id" => game_id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.game_path(conn, :show, id: game_id))

      name1 = p1.username
      name2 = p2.username

      assert %{
        "p1_name" => ^name1,
        "p2_name" => ^name2,
        "completed?" => false
      } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid or missing", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create, user: nil, opponent: nil))
      assert json_response(conn, 400)["errors"] != %{}

      conn = post(conn, Routes.game_path(conn, :create))
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "show game" do
    setup [:create_game]

    test "renders game when input is valid", %{conn: conn, game: game} do
      conn = get(conn, Routes.game_path(conn, :show, id: game.game_id))
      id = game.game_id
      name1 = game.p1_name
      name2 = game.p2_name
      assert %{
        "game_id" => ^id,
        "p1_name" => ^name1,
        "p2_name" => ^name2,
        "p1_card" => false,
        "p2_card" => false,
      } = json_response(conn, 200)["data"]
    end

    test "renders game with cards visible for user that is optionally provided as a param", %{conn: conn, game: game} do
      conn = get(conn, Routes.game_path(conn, :show, id: game.game_id, user: game.p1_uuid))
      id = game.game_id
      name1 = game.p1_name
      name2 = game.p2_name
      assert %{
        "game_id" => ^id,
        "p1_name" => ^name1,
        "p2_name" => ^name2,
        "p1_card" => nil,
        "p2_card" => false,
      } = json_response(conn, 200)["data"]

      Games.update_game(%{"id" => game.game_id, "user" => game.p2_uuid, "card" => "1"})
      conn = get(conn, Routes.game_path(conn, :show, id: game.game_id, user: game.p2_uuid))
      assert %{
        "game_id" => ^id,
        "p1_name" => ^name1,
        "p2_name" => ^name2,
        "p1_card" => false,
        "p2_card" => 1,
      } = json_response(conn, 200)["data"]

      conn = get(conn, Routes.game_path(conn, :show, id: game.game_id, user: game.p1_uuid))
      assert %{
        "game_id" => ^id,
        "p1_name" => ^name1,
        "p2_name" => ^name2,
        "p1_card" => nil,
        "p2_card" => true,
      } = json_response(conn, 200)["data"]
    end

    test "reveals player cards if spy is active", %{conn: conn, game: game} do
      Games.update_game(%{"id" => game.game_id, "user" => game.p1_uuid, "card" => "2"})
      Games.update_game(%{"id" => game.game_id, "user" => game.p2_uuid, "card" => "1"})
      Games.update_game(%{"id" => game.game_id, "user" => game.p2_uuid, "card" => "3"})

      conn = get(conn, Routes.game_path(conn, :show, id: game.game_id))
      id = game.game_id
      name1 = game.p1_name
      name2 = game.p2_name
      assert %{
        "game_id" => ^id,
        "p1_name" => ^name1,
        "p2_name" => ^name2,
        "p1_card" => false,
        "p2_card" => 3,
      } = json_response(conn, 200)["data"]

    end

    test "returns error when input is invalid", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :show))
      assert json_response(conn, 400)["errors"] != %{}
    end

  end

  describe "update game" do
    setup [:create_game]

    test "renders updated game when input is valid", %{conn: conn, game: %Game{game_id: id, p1_uuid: user, p2_name: opponent} = _game} do
      conn = patch(conn, Routes.game_path(conn, :update, id: id, user: user, opponent: opponent, card: 1))
      assert %{"p1_card" => 1} = json_response(conn, 200)["data"]
    end

    test "renders errors when input is invalid", %{conn: conn, game: %Game{game_id: id}} do
      conn = patch(conn, Routes.game_path(conn, :update))
      assert json_response(conn, 400)["errors"] != %{}

      conn = patch(conn, Routes.game_path(conn, :update, id: id, user: "invalid uuid", card: 1))
      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  defp create_game(_) do
    game = fixture(:game)
    %{game: game}
  end

  defp create_users(_) do
    p1 = fixture(:p1)
    p2 = fixture(:p2)
    %{p1: p1, p2: p2}
  end
end
