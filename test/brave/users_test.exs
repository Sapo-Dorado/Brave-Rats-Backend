defmodule Brave.UsersTest do
  use Brave.DataCase

  alias Brave.Users

  describe "users" do
    alias Brave.Users.User

    @valid_attrs %{username: "some username", password: "some password"}
    @invalid_attrs %{username: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(%{"username" => @valid_attrs.username,"password" => @valid_attrs.password})
        |> Users.create_user()

      user
    end

    test "get_uuid/1 returns the users uuid if data is valid and returns an error otherwise" do
      user = user_fixture()
      assert Users.get_uuid(%{"username" => user.username, "password" => @valid_attrs.password}) == %{uuid: user.uuid}
      assert Users.get_uuid(%{"username" => user.username, "password" => "invalid password"}) == %{errors: %{"password" => ["invalid password"]}}
      assert Users.get_uuid(%{"username" => "invalid username", "password" => @valid_attrs.password}) == %{errors: %{"username" => ["invalid username"]}}
      assert Users.get_uuid(%{"password" => @valid_attrs.password}) == %{errors: %{"username" => ["required field"]}}
      assert Users.get_uuid(%{"username" => user.username}) == %{errors: %{"password" => ["required field"]}}
      assert Users.get_uuid(%{}) == %{errors: %{"username" => ["required field"], "password" => ["required field"]}}
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(%{"username" => @valid_attrs.username, "password" => @valid_attrs.password})
      assert Argon2.verify_pass(@valid_attrs.password, user.password_hash)
      assert user.username == @valid_attrs.username
      assert user.uuid != nil
    end

    test "create_user/1 with invalid changeset data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(%{"username" => @invalid_attrs.username, "password" => @invalid_attrs.password})
    end

    test "create_user/1 returns an error changeset when username is already taken" do
      Users.create_user(%{"username" => @valid_attrs.username, "password" => @valid_attrs.password})
      assert {:error, %Ecto.Changeset{}} = Users.create_user(%{"username" => @valid_attrs.username, "password" => @valid_attrs.password})
    end

    test "create_user/1 with invalid parameters returns errors" do
      assert %{errors: %{"password" => ["required field"]}} = Users.create_user(%{"username" => @valid_attrs.username})
      assert %{errors: %{"username" => ["required field"]}} = Users.create_user(%{"password" => @valid_attrs.password})
      assert %{errors: %{"username" => ["required field"], "password" => ["required field"]}} = Users.create_user(%{})
    end

    test "get_user_by_uuid/1 and get_user_by_username/1 return the desired user when input is valid" do
      user = user_fixture()
      assert Users.get_user_by_uuid(user.uuid) == {:ok, user}
      assert Users.get_user_by_username(user.username) == {:ok, user}
    end

    test "get_user_by_uuid/1 and get_user_by_username/1 return errors when input is invalid" do
      assert %{errors: %{"uuid" => ["invalid uuid"]}} = Users.get_user_by_uuid("invalid uuid")
      assert %{errors: %{"username" => ["invalid username"]}} = Users.get_user_by_username("invalid username")
    end

  end
end
