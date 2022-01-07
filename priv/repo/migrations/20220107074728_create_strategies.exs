defmodule KuraBackend.Repo.Migrations.CreateStrategy do
  use Ecto.Migration

  def change do
    create table(:strategies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :label, :string
      add :legs, :integer

      timestamps()
    end
  end
end
