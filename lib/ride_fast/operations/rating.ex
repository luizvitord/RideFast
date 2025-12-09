defmodule RideFast.Operations.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :score, :integer
    field :comment, :string

    belongs_to :ride, RideFast.Operations.Ride
    belongs_to :from_user, RideFast.Accounts.User, foreign_key: :from_user_id
    belongs_to :to_driver, RideFast.Accounts.Driver, foreign_key: :to_driver_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:score, :comment, :ride_id, :from_user_id, :to_driver_id])
    |> validate_required([:score, :comment, :ride_id, :from_user_id, :to_driver_id])
  end
end
