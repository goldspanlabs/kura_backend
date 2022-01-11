defmodule Kura.Goals.Goal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "goals" do
    field :amount, :decimal
    field :interval, :string
    field :root, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(goal, attrs) do
    goal
    |> cast(attrs, [:amount, :interval, :root])
    |> validate_required([:amount, :interval, :root])
  end
end
