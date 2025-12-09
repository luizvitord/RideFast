defmodule RideFast.OperationsTest do
  use RideFast.DataCase

  alias RideFast.Operations
  alias RideFast.Operations.Ride
  import RideFast.OperationsFixtures
  import RideFast.AccountsFixtures
  import RideFast.FleetFixtures

  describe "rides" do
    @invalid_attrs %{status: nil, price_estimate: nil, final_price: nil}

    test "list_rides/0 returns all rides" do
      # Cria atores para garantir que o preload funcione
      user = user_fixture()
      driver = driver_fixture()
      vehicle = vehicle_fixture(%{driver_id: driver.id})

      # Cria a ride vinculada
      ride = ride_fixture(%{user_id: user.id, driver_id: driver.id, vehicle_id: vehicle.id})

      # Busca do banco
      [fetched_ride] = Operations.list_rides()

      # Compara IDs (evita erro de comparação de associações carregadas vs não carregadas)
      assert fetched_ride.id == ride.id
    end

    test "get_ride!/1 returns the ride with given id" do
      user = user_fixture()
      ride = ride_fixture(%{user_id: user.id})

      fetched_ride = Operations.get_ride!(ride.id)
      assert fetched_ride.id == ride.id
      # Verifica se fez o preload
      assert Ecto.assoc_loaded?(fetched_ride.user)
    end

    test "create_ride/1 with valid data creates a ride" do
      user = user_fixture()

      valid_attrs = %{
        origin_lat: 120.5,
        origin_lng: 120.5,
        dest_lat: 120.5,
        dest_lng: 120.5,
        price_estimate: "120.5",
        status: :requested,
        user_id: user.id,
        requested_at: NaiveDateTime.utc_now()
      }

      assert {:ok, %Ride{} = ride} = Operations.create_ride(valid_attrs)
      assert ride.status == :requested
      assert ride.origin_lat == 120.5
      assert ride.price_estimate == Decimal.new("120.5")
    end

    test "create_ride/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operations.create_ride(@invalid_attrs)
    end

    # --- TESTES DA MÁQUINA DE ESTADOS (FLUXO REAL) ---

    test "fluxo: solicitar -> aceitar -> iniciar -> finalizar" do
      user = user_fixture()
      driver = driver_fixture()
      vehicle = vehicle_fixture(%{driver_id: driver.id})

      # 1. Criar (Solicitada)
      ride = ride_fixture(%{user_id: user.id, status: :requested})

      # 2. Aceitar
      assert {:ok, %Ride{} = accepted} = Operations.accept_ride(ride.id, driver.id, vehicle.id)
      assert accepted.status == :accepted
      assert accepted.driver_id == driver.id

      # 3. Iniciar
      assert {:ok, %Ride{} = started} = Operations.start_ride(accepted)
      assert started.status == :in_progress
      assert started.started_at != nil

      # 4. Finalizar
      final_price = Decimal.new("50.00")
      assert {:ok, %Ride{} = finished} = Operations.complete_ride(started, final_price)
      assert finished.status == :finished
      assert finished.final_price == final_price
      assert finished.ended_at != nil
    end

    test "accept_ride/3 falha se status não for requested" do
      user = user_fixture()
      driver = driver_fixture()
      vehicle = vehicle_fixture(%{driver_id: driver.id})

      # Ride já iniciada
      ride = ride_fixture(%{user_id: user.id, status: :in_progress})

      assert {:error, _} = Operations.accept_ride(ride.id, driver.id, vehicle.id)
    end

    test "cancel_ride/1 cancela corrida solicitada ou aceita" do
      user = user_fixture()
      ride = ride_fixture(%{user_id: user.id, status: :requested})

      assert {:ok, canceled} = Operations.cancel_ride(ride)
      assert canceled.status == :canceled
    end
  end

  # Testes de Ratings mantidos e ajustados
  describe "ratings" do
    alias RideFast.Operations.Rating
    import RideFast.OperationsFixtures

    @invalid_attrs %{comment: nil, score: nil}

test "create_rating/1 with valid data creates a rating" do
      user = user_fixture()
      driver = driver_fixture()
      vehicle = vehicle_fixture(%{driver_id: driver.id})
      ride = ride_fixture(%{user_id: user.id, driver_id: driver.id, vehicle_id: vehicle.id, status: :finished})

      valid_attrs = %{
        comment: "some comment",
        score: 5,
        ride_id: ride.id,
        from_user_id: user.id,
        to_driver_id: driver.id
      }

      assert {:ok, %Rating{} = rating} = Operations.create_rating(valid_attrs)
      assert rating.comment == "some comment"
      assert rating.score == 5
      assert rating.ride_id == ride.id
      assert rating.from_user_id == user.id
    end
  end
end
