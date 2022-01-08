defmodule KuraBackend.Repo.Migrations.CreateStrategy do
  use Ecto.Migration

  def change do
    create table(:strategies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string
      add :legs, :integer

      timestamps()
    end

    create unique_index(:strategies, [:label])
  end
end
