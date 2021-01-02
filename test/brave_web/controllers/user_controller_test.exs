defmodule BraveWeb.UserControllerTest do
  use BraveWeb.ConnCase

  alias Brave.Users

  @create_attrs %{
    username: "some username",
    password: "some password"
  }

  @invalid_attrs %{username: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Users.create_user(%{"username" => @create_attrs.username, "password" => @create_attrs.password})
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show user" do
    setup [:create_user]

    test "renders valid user when data is valid", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show,
          username: @create_attrs.username,
          password: @create_attrs.password))
      assert %{"uuid" => uuid} = json_response(conn, 200)["data"]
    end

    test "returns 401 error when password is incorrect", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show,
          username: @create_attrs.username,
          password: "invalid password"))
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "returns 400 error when data is invalid", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show,
          username: "invalid username",
          password: @create_attrs.password))
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create,
          username: @create_attrs.username,
          password: @create_attrs.password))
      assert %{"uuid" => uuid} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show,
          username: @create_attrs.username,
          password: @create_attrs.password))

      assert %{"uuid" => uuid} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create,
          username: @invalid_attrs.username,
          password: @invalid_attrs.password))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
