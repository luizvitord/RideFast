defmodule RideFast.Repo.Migrations.AddRoleFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, default: "passenger", null: false
    end

    alter table(:drivers) do
      add :role, :string, default: "driver", null: false
    end
  end
end
