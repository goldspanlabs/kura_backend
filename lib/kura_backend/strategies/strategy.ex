defmodule KuraBackend.Strategies.Strategy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "strategies" do
    field :label, :string
    field :legs, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(strategy, attrs) do
    strategy
    |> cast(attrs, [:name, :label, :legs])
    |> validate_required([:name, :label, :legs])
  end
end
