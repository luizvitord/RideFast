defmodule RideFast.Operations.Ride do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rides" do
    field :origin_lat, :float
    field :origin_lng, :float
    field :dest_lat, :float
    field :dest_lng, :float
    field :status, Ecto.Enum, values: [:requested, :accepted, :in_progress, :finished, :canceled], default: :requested
    field :requested_at, :naive_datetime
    field :started_at, :naive_datetime
    field :ended_at, :naive_datetime
    field :price_estimate, :decimal
    field :final_price, :decimal

    belongs_to :user, RideFast.Accounts.User
    belongs_to :driver, RideFast.Accounts.Driver
    belongs_to :vehicle, RideFast.Fleet.Vehicle
    has_many :ratings, RideFast.Operations.Rating

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ride, attrs) do
    ride
    # 1. Adicione user_id, driver_id, vehicle_id no cast
    |> cast(attrs, [
      :origin_lat, :origin_lng, :dest_lat, :dest_lng,
      :status, :requested_at, :started_at, :ended_at,
      :price_estimate, :final_price,
      :user_id, :driver_id, :vehicle_id
    ])
    # 2. Remova started_at, ended_at, final_price do validate_required (são opcionais no início)
    |> validate_required([
      :origin_lat, :origin_lng, :dest_lat, :dest_lng,
      :status, :requested_at, :price_estimate, :user_id
    ])
  end
end
