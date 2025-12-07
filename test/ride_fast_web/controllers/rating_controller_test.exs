defmodule RideFastWeb.RatingControllerTest do
  use RideFastWeb.ConnCase

  import RideFast.AccountsFixtures
  import RideFast.FleetFixtures
  import RideFast.OperationsFixtures
  alias RideFast.Auth.Guardian

  setup %{conn: conn} do
    user = user_fixture()
    driver = driver_fixture()
    vehicle = vehicle_fixture(%{driver_id: driver.id})

    # Cria token do usuário
    {:ok, token, _} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer " <> token)

    %{conn: conn, user: user, driver: driver, vehicle: vehicle}
  end

  describe "Avaliar corrida" do
    test "sucesso ao avaliar corrida finalizada", %{conn: conn, user: user, driver: driver, vehicle: vehicle} do
      # Cria corrida finalizada
      ride = ride_fixture(%{
        user_id: user.id,
        driver_id: driver.id,
        vehicle_id: vehicle.id,
        status: :finished
      })

      params = %{score: 5, comment: "Excelente motorista!"}
      conn = post(conn, ~p"/api/v1/rides/#{ride.id}/ratings", params)

      assert json_response(conn, 201)["data"]["comment"] == "Excelente motorista!"
    end

    test "erro ao avaliar corrida em andamento", %{conn: conn, user: user, driver: driver, vehicle: vehicle} do
      # Cria corrida em andamento
      ride = ride_fixture(%{
        user_id: user.id,
        driver_id: driver.id,
        vehicle_id: vehicle.id,
        status: :in_progress
      })

      params = %{score: 5, comment: "Tentando avaliar cedo demais"}
      conn = post(conn, ~p"/api/v1/rides/#{ride.id}/ratings", params)

      assert json_response(conn, 400)["error"] =~ "Apenas corridas finalizadas"
    end
  end
end
