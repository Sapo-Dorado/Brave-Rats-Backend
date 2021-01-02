defmodule BraveWeb.UserView do
  use BraveWeb, :view

  def render("show.json", %{uuid: uuid}) do
    %{data: %{uuid: uuid}}
  end
end
