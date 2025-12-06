defmodule RideFast.Accounts.Driver do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drivers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :password_hash, :string
    field :status, :string
    field :role, Ecto.Enum, values: [:driver], default: :driver

    has_one :profile, RideFast.Accounts.DriverProfile

    has_many :vehicles, RideFast.Fleet.Vehicle
    has_many :rides, RideFast.Operations.Ride

    many_to_many :languages, RideFast.Global.Language,
      join_through: RideFast.Global.DriverLanguage,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(driver, attrs) do
    driver
    |> cast(attrs, [:name, :email, :phone, :password_hash, :status, :role])
    |> validate_required([:name, :email, :phone, :password_hash, :status])
    |> unique_constraint(:email)
    |> put_change(:role, :driver)
  end
end
