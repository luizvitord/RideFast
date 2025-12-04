defmodule RideFast.OperationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RideFast.Operations` context.
  """

  @doc """
  Generate a ride.
  """
  def ride_fixture(attrs \\ %{}) do
    {:ok, ride} =
      attrs
      |> Enum.into(%{
        dest_lat: 120.5,
        dest_lng: 120.5,
        ended_at: ~N[2025-12-02 23:30:00],
        final_price: "120.5",
        origin_lat: 120.5,
        origin_lng: 120.5,
        price_estimate: "120.5",
        requested_at: ~N[2025-12-02 23:30:00],
        started_at: ~N[2025-12-02 23:30:00],
        status: "some status"
      })
      |> RideFast.Operations.create_ride()

    ride
  end

  @doc """
  Generate a rating.
  """
  def rating_fixture(attrs \\ %{}) do
    {:ok, rating} =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        score: 42
      })
      |> RideFast.Operations.create_rating()

    rating
  end
end
