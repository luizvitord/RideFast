defmodule RideFast.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :password_hash, :string
    field :role, Ecto.Enum, values: [:user, :admin], default: :user
    field :password, :string, virtual: true
    field :deleted_at, :naive_datetime

    has_many :rides, RideFast.Operations.Ride
    has_many :ratings_given, RideFast.Operations.Rating, foreign_key: :from_user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
|> cast(attrs, [:name, :email, :phone, :password, :role])
    |> validate_required([:name, :email, :password])
    |> unique_constraint(:email)
    |> put_change(:role, :user)
    |> put_password_hash()
  end

  def admin_changeset(user, attrs) do
  user
  |> cast(attrs, [:name, :email, :phone, :password, :role])
  |> validate_required([:name, :email, :password])
  |> unique_constraint(:email)
  |> put_change(:role, :admin)
  |> put_password_hash()
end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :phone, :password])
    |> validate_required([:name, :email])
    |> validate_length(:password, min: 6)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end
