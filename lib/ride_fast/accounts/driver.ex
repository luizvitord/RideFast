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
    field :password, :string, virtual: true

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
    |> cast(attrs, [:name, :email, :phone, :password, :status, :role])
    |> validate_required([:name, :email, :phone])
    |> validate_password(attrs)
    |> unique_constraint(:email)
    |> put_change(:role, :driver)
    |> put_password_hash()
  end

  defp validate_password(changeset, attrs) do
    if changeset.data.id == nil do
      validate_required(changeset, [:password])
    else
      changeset
    end
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end

end
