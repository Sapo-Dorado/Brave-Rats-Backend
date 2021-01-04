defmodule Brave.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :game_id, :string
      add :p1_uuid, :string
      add :p2_uuid, :string
      add :p1_name, :string
      add :p2_name, :string
      add :p1_card, :integer
      add :p2_card, :integer
      add :p1_points, :integer, default: 0
      add :p2_points, :integer, default: 0
      add :p1_winnings, {:array, {:array, :integer}}
      add :p2_winnings, {:array, {:array, :integer}}
      add :p1_cards, {:array, :integer}
      add :p2_cards, {:array, :integer}
      add :on_hold, {:array, {:array, :integer}}
      add :p1_general?, :boolean, default: false, null: false
      add :p2_general?, :boolean, default: false, null: false
      add :p1_spy?, :boolean, default: false, null: false
      add :p2_spy?, :boolean, default: false, null: false
      add :completed?, :boolean, default: false, null: false

      timestamps()
    end

  end
end
