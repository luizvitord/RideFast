defmodule RideFast.Repo.Migrations.CreateDriversLanguages do
  use Ecto.Migration

  def change do
    create table(:drivers_languages) do
      add :driver_id, references(:drivers, on_delete: :nothing)
      add :language_id, references(:languages, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:drivers_languages, [:driver_id, :language_id])
  end
end
