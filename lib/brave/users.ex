defmodule Brave.Users do
  import Ecto.Query, warn: false
  alias Brave.Repo

  alias Brave.Users.User

  def get_uuid(%{"username" => username, "password" => password}) do
    query =
      from u in User,
        where: u.username == ^username
    case query |> Repo.one() do
      nil ->
        %{errors: %{"username" => ["invalid username"]}}
      user ->
        if(Argon2.verify_pass(password, user.password_hash)) do
          %{uuid: user.uuid}
        else
          %{errors: %{"password" => ["invalid password"]}}
        end
    end
  end

  def get_uuid(params) do
    Brave.find_missing_params(params, ["username", "password"])
  end

  def create_user(%{"username" => username, "password" => password}) do
    %User{}
    |> User.changeset(%{username: username, password_hash: password, uuid: Ecto.UUID.generate})
    |> Repo.insert()
  end

  def create_user(params) do
    Brave.find_missing_params(params, ["username", "password"])
  end

  def get_user_by_uuid(uuid) do
    query =
      from u in User,
        where: u.uuid == ^uuid
    case Repo.one(query) do
      nil ->
        %{errors: %{"uuid" => ["invalid uuid"]}}
      user ->
        {:ok, user}
    end
  end

  def get_user_by_username(username) do
    query =
      from u in User,
        where: u.username == ^username
    case Repo.one(query) do
      nil ->
        %{errors: %{"username" => ["invalid username"]}}
      user ->
        {:ok, user}
    end
  end
end
