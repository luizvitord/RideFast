defmodule RideFastWeb.RideJSON do
  alias RideFast.Operations.Ride

  def index(%{rides: rides}) do
    %{data: for(ride <- rides, do: data(ride))}
  end

  def show(%{ride: ride}) do
    %{data: data(ride)}
  end

  def data(%Ride{} = ride) do
    %{
      id: ride.id,
      status: ride.status,
      origin: %{
        lat: ride.origin_lat,
        lng: ride.origin_lng
      },
      destination: %{
        lat: ride.dest_lat,
        lng: ride.dest_lng
      },
      price_estimate: ride.price_estimate,
      final_price: ride.final_price,
      requested_at: ride.requested_at,
      started_at: ride.started_at,
      ended_at: ride.ended_at,
      user_id: ride.user_id,
      driver_id: ride.driver_id,
      vehicle_id: ride.vehicle_id,
      driver: if(Ecto.assoc_loaded?(ride.driver) && ride.driver, do: %{name: ride.driver.name, id: ride.driver.id}, else: nil),
      vehicle: if(Ecto.assoc_loaded?(ride.vehicle) && ride.vehicle, do: %{plate: ride.vehicle.plate, model: ride.vehicle.model}, else: nil)
    }
  end
end
