defmodule BraveWeb.UserController do
  use BraveWeb, :controller

  alias Brave.Users
  alias Brave.Users.User

  action_fallback BraveWeb.FallbackController

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, username: user_params["username"], password: user_params["password"]))
      |> render("show.json", uuid: user.uuid)
    end
  end

  def show(conn, params) do
    with %{uuid: uuid} <- Users.get_uuid(params) do
      render(conn, "show.json", uuid: uuid)
    end
  end

end
