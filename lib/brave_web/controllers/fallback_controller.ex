defmodule BraveWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BraveWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BraveWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BraveWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, %{errors: errors}) do
    conn
    |> get_status(errors)
    |> put_view(BraveWeb.ErrorView)
    |> render("error.json", errors: errors)
  end

  defp get_status(conn, errors) do
    case errors do
      %{"password" => ["invalid password"]} ->
        put_status(conn, :unauthorized)
      _ ->
        put_status(conn, :bad_request)
    end
  end
end
