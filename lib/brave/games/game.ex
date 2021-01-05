defmodule Brave.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :completed?, :boolean, default: false
    field :game_id, :string
    field :on_hold, {:array, {:array, :integer}}
    field :p1_card, :integer
    field :p1_cards, {:array, :integer}
    field :p1_general?, :boolean, default: false
    field :p1_spy?, :boolean, default: false
    field :p1_name, :string
    field :p1_points, :integer, default: 0
    field :p1_uuid, :string
    field :p1_winnings, {:array, {:array, :integer}}
    field :p2_card, :integer
    field :p2_cards, {:array, :integer}
    field :p2_general?, :boolean, default: false
    field :p2_spy?, :boolean, default: false
    field :p2_name, :string
    field :p2_points, :integer, default: 0
    field :p2_uuid, :string
    field :p2_winnings, {:array, {:array, :integer}}

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:game_id, :p1_uuid, :p2_uuid, :p1_name, :p2_name, :p1_card, :p2_card, :p1_points, :p2_points, :p1_winnings, :p2_winnings, :p1_cards, :p2_cards, :on_hold, :p1_general?, :p2_general?, :p1_spy?, :p2_spy?, :completed?])
    |> validate_required([:game_id, :p1_uuid, :p2_uuid, :p1_name, :p2_name, :p1_winnings, :p2_winnings, :p1_cards, :p2_cards, :on_hold])
  end
end
