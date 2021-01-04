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

      uuid1 = p1.uuid
      uuid2 = p2.uuid
      name1 = p1.username
      name2 = p2.username

      assert %{
        "p1_uuid" => ^uuid1,
        "p2_uuid" => ^uuid2,
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
      uuid1 = game.p1_uuid
      uuid2 = game.p2_uuid
      name1 = game.p1_name
      name2 = game.p2_name
      assert %{
        "game_id" => ^id,
        "p1_uuid" => ^uuid1,
        "p2_uuid" => ^uuid2,
        "p1_name" => ^name1,
        "p2_name" => ^name2
      } = json_response(conn, 200)["data"]
    end

    test "returns error when input is invalid", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :show))
      assert json_response(conn, 400)["errors"] != %{}
    end

  end

  describe "update game" do
    setup [:create_game]

    test "placeholder test", %{conn: conn, game: %Game{game_id: id, p1_uuid: user, p2_name: opponent} = _game} do
      conn = patch(conn, Routes.game_path(conn, :update, id: id, user: user, opponent: opponent, card: 1))
      assert %{"good job" => ["not implemented yet"]} = json_response(conn, 400)["errors"]
    end

    test "renders errors when input is invalid", %{conn: conn} do
      conn = patch(conn, Routes.game_path(conn, :update))
      assert json_response(conn, 400)["errors"] != %{}
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
