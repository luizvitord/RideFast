defmodule RideFast.Repo.Migrations.ModifyStatusInRides do
  use Ecto.Migration

def up do
    # Opcional: Se você já tiver dados "sujos" ou vazios, limpe-os antes
    # execute "UPDATE rides SET status = 'requested' WHERE status IS NULL"

    alter table(:rides) do
      # Modifica a coluna para ter um padrão e não aceitar nulo
      modify :status, :string, default: "requested", null: false
    end
  end

  def down do
    alter table(:rides) do
      # Reverte para string simples (sem padrão obrigatório)
      modify :status, :string, default: nil, null: true
    end
  end
end
