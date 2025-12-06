defmodule RideFast.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :password_hash, :string
    field :role, Ecto.Enum, values: [:passenger, :admin], default: :passenger

    has_many :rides, RideFast.Operations.Ride
    has_many :ratings_given, RideFast.Operations.Rating, foreign_key: :from_user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :phone, :password_hash, :role])
    |> validate_required([:name, :email, :phone, :password_hash])
    |> unique_constraint(:email)
    |> put_change(:role, :passenger)
  end
end
