defmodule RideFast.Repo.Migrations.CreateUserFavoriteDrivers do
  use Ecto.Migration

  def change do
    create table(:user_favorite_drivers, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false

      add :driver_id, references(:drivers, on_delete: :delete_all), null: false
    end

    create unique_index(:user_favorite_drivers, [:user_id, :driver_id])
  end
end
