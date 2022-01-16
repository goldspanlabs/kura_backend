defmodule Kura.Strategies.Strategy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "strategies" do
    field :label, :string
    field :legs, :integer

    timestamps()
  end

  @doc false
  def changeset(strategy, attrs) do
    strategy
    |> cast(attrs, [:id, :label, :legs])
    |> validate_required([:id, :label, :legs])
  end
end
