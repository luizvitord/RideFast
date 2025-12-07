defmodule RideFastWeb.VehicleJSON do
  alias RideFast.Fleet.Vehicle

  def index(%{vehicles: vehicles}) do
    %{data: for(vehicle <- vehicles, do: data(vehicle))}
  end

  def show(%{vehicle: vehicle}) do
    %{data: data(vehicle)}
  end

  def data(%Vehicle{} = vehicle) do
    %{
      id: vehicle.id,
      driver_id: vehicle.driver_id,
      plate: vehicle.plate,
      model: vehicle.model,
      color: vehicle.color,
      seats: vehicle.seats,
      active: vehicle.active,
      inserted_at: vehicle.inserted_at
    }
  end
end
