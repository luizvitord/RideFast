defmodule RideFast.OperationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RideFast.Operations` context.
  """
  import RideFast.AccountsFixtures
  import RideFast.FleetFixtures

  def ride_fixture(attrs \\ %{}) do
    # Garante relacionamentos se não passados
    user_id = attrs[:user_id] || user_fixture().id

    # Se status for diferente de requested, precisamos de driver e vehicle
    {driver_id, vehicle_id} =
      if attrs[:status] && attrs[:status] != :requested do
        d = driver_fixture()
        v = vehicle_fixture(%{driver_id: d.id})
        {d.id, v.id}
      else
        {nil, nil}
      end

    {:ok, ride} =
      attrs
      |> Enum.into(%{
        dest_lat: 120.5,
        dest_lng: 120.5,
        origin_lat: 120.5,
        origin_lng: 120.5,
        price_estimate: "120.5",
        requested_at: ~N[2025-12-02 23:30:00],
        status: :requested,
        user_id: user_id,
        driver_id: driver_id,
        vehicle_id: vehicle_id
      })
      |> RideFast.Operations.create_ride()

    ride
  end

  def rating_fixture(attrs \\ %{}) do
    {:ok, rating} =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        score: 5
      })
      |> RideFast.Operations.create_rating()

    rating
  end
end
