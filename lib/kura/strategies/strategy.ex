defmodule Kura.Strategies.Strategy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "strategies" do
    field :label, :string
    field :legs, :integer

    timestamps()
  end

  @doc false
  def changeset(strategy, attrs) do
    strategy
    |> cast(attrs, [:label, :legs])
    |> validate_required([:label, :legs])
  end
end
