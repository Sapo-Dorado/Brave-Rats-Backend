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
    user_errors(params)
  end

  def create_user(%{"username" => username, "password" => password}) do
    %User{}
    |> User.changeset(%{username: username, password_hash: password, uuid: Ecto.UUID.generate})
    |> Repo.insert()
  end

  def create_user(params) do
    user_errors(params)
  end

  defp user_errors(params) do
    errors = Enum.reduce(["username", "password"], %{}, fn(field, acc) ->
      if(params[field] == nil) do
        Map.put(acc, field, ["required field"])
      else
        acc
      end
    end)
    %{errors: errors}
  end
end
