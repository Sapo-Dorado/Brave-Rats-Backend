defmodule Brave.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :password_hash, :string
    field :username, :string
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password_hash, :uuid])
    |> validate_required([:username, :password_hash, :uuid])
    |> unique_constraint(:username)
  end
end
