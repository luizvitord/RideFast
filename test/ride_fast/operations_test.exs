defmodule RideFast.OperationsTest do
  use RideFast.DataCase

  alias RideFast.Operations

  describe "rides" do
    alias RideFast.Operations.Ride

    import RideFast.OperationsFixtures

    @invalid_attrs %{status: nil, started_at: nil, origin_lat: nil, origin_lng: nil, dest_lat: nil, dest_lng: nil, requested_at: nil, ended_at: nil, price_estimate: nil, final_price: nil}

    test "list_rides/0 returns all rides" do
      ride = ride_fixture()
      assert Operations.list_rides() == [ride]
    end

    test "get_ride!/1 returns the ride with given id" do
      ride = ride_fixture()
      assert Operations.get_ride!(ride.id) == ride
    end

    test "create_ride/1 with valid data creates a ride" do
      valid_attrs = %{status: "some status", started_at: ~N[2025-12-02 23:30:00], origin_lat: 120.5, origin_lng: 120.5, dest_lat: 120.5, dest_lng: 120.5, requested_at: ~N[2025-12-02 23:30:00], ended_at: ~N[2025-12-02 23:30:00], price_estimate: "120.5", final_price: "120.5"}

      assert {:ok, %Ride{} = ride} = Operations.create_ride(valid_attrs)
      assert ride.status == "some status"
      assert ride.started_at == ~N[2025-12-02 23:30:00]
      assert ride.origin_lat == 120.5
      assert ride.origin_lng == 120.5
      assert ride.dest_lat == 120.5
      assert ride.dest_lng == 120.5
      assert ride.requested_at == ~N[2025-12-02 23:30:00]
      assert ride.ended_at == ~N[2025-12-02 23:30:00]
      assert ride.price_estimate == Decimal.new("120.5")
      assert ride.final_price == Decimal.new("120.5")
    end

    test "create_ride/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operations.create_ride(@invalid_attrs)
    end

    test "update_ride/2 with valid data updates the ride" do
      ride = ride_fixture()
      update_attrs = %{status: "some updated status", started_at: ~N[2025-12-03 23:30:00], origin_lat: 456.7, origin_lng: 456.7, dest_lat: 456.7, dest_lng: 456.7, requested_at: ~N[2025-12-03 23:30:00], ended_at: ~N[2025-12-03 23:30:00], price_estimate: "456.7", final_price: "456.7"}

      assert {:ok, %Ride{} = ride} = Operations.update_ride(ride, update_attrs)
      assert ride.status == "some updated status"
      assert ride.started_at == ~N[2025-12-03 23:30:00]
      assert ride.origin_lat == 456.7
      assert ride.origin_lng == 456.7
      assert ride.dest_lat == 456.7
      assert ride.dest_lng == 456.7
      assert ride.requested_at == ~N[2025-12-03 23:30:00]
      assert ride.ended_at == ~N[2025-12-03 23:30:00]
      assert ride.price_estimate == Decimal.new("456.7")
      assert ride.final_price == Decimal.new("456.7")
    end

    test "update_ride/2 with invalid data returns error changeset" do
      ride = ride_fixture()
      assert {:error, %Ecto.Changeset{}} = Operations.update_ride(ride, @invalid_attrs)
      assert ride == Operations.get_ride!(ride.id)
    end

    test "delete_ride/1 deletes the ride" do
      ride = ride_fixture()
      assert {:ok, %Ride{}} = Operations.delete_ride(ride)
      assert_raise Ecto.NoResultsError, fn -> Operations.get_ride!(ride.id) end
    end

    test "change_ride/1 returns a ride changeset" do
      ride = ride_fixture()
      assert %Ecto.Changeset{} = Operations.change_ride(ride)
    end
  end

  describe "ratings" do
    alias RideFast.Operations.Rating

    import RideFast.OperationsFixtures

    @invalid_attrs %{comment: nil, score: nil}

    test "list_ratings/0 returns all ratings" do
      rating = rating_fixture()
      assert Operations.list_ratings() == [rating]
    end

    test "get_rating!/1 returns the rating with given id" do
      rating = rating_fixture()
      assert Operations.get_rating!(rating.id) == rating
    end

    test "create_rating/1 with valid data creates a rating" do
      valid_attrs = %{comment: "some comment", score: 42}

      assert {:ok, %Rating{} = rating} = Operations.create_rating(valid_attrs)
      assert rating.comment == "some comment"
      assert rating.score == 42
    end

    test "create_rating/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operations.create_rating(@invalid_attrs)
    end

    test "update_rating/2 with valid data updates the rating" do
      rating = rating_fixture()
      update_attrs = %{comment: "some updated comment", score: 43}

      assert {:ok, %Rating{} = rating} = Operations.update_rating(rating, update_attrs)
      assert rating.comment == "some updated comment"
      assert rating.score == 43
    end

    test "update_rating/2 with invalid data returns error changeset" do
      rating = rating_fixture()
      assert {:error, %Ecto.Changeset{}} = Operations.update_rating(rating, @invalid_attrs)
      assert rating == Operations.get_rating!(rating.id)
    end

    test "delete_rating/1 deletes the rating" do
      rating = rating_fixture()
      assert {:ok, %Rating{}} = Operations.delete_rating(rating)
      assert_raise Ecto.NoResultsError, fn -> Operations.get_rating!(rating.id) end
    end

    test "change_rating/1 returns a rating changeset" do
      rating = rating_fixture()
      assert %Ecto.Changeset{} = Operations.change_rating(rating)
    end
  end
end
