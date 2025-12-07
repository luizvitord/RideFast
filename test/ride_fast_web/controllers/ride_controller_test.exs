defmodule RideFastWeb.RideControllerTest do
  use RideFastWeb.ConnCase

  import RideFast.AccountsFixtures
  import RideFast.FleetFixtures
  import RideFast.OperationsFixtures

  alias RideFast.Auth.Guardian

  # Função auxiliar para gerar token e adicionar no header
  defp authenticated_conn(conn, user) do
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  setup %{conn: conn} do
    # Prepara o cenário: 1 Passageiro, 1 Motorista com Veículo
    passenger = user_fixture()
    driver = driver_fixture()
    vehicle = vehicle_fixture(%{driver_id: driver.id})

    # Cria conexões autenticadas para cada um
    passenger_conn = authenticated_conn(conn, passenger)
    driver_conn = authenticated_conn(conn, driver)

    %{
      passenger: passenger,
      driver: driver,
      vehicle: vehicle,
      passenger_conn: passenger_conn,
      driver_conn: driver_conn
    }
  end

  describe "Fluxo Completo da Corrida" do
    test "solicitar -> aceitar -> iniciar -> finalizar", %{passenger_conn: p_conn, driver_conn: d_conn, vehicle: vehicle} do
      # 1. Solicitar (Passageiro)
      create_attrs = %{
        origin: %{lat: -3.7, lng: -38.5},
        destination: %{lat: -3.8, lng: -38.6},
        payment_method: "CARD"
      }

      conn = post(p_conn, ~p"/api/v1/rides", create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      # O ID vem como string/inteiro no JSON, vamos garantir que temos ele para as próximas chamadas
      ride_id = id

      # 2. Aceitar (Motorista)
      conn = post(d_conn, ~p"/api/v1/rides/#{ride_id}/accept", %{vehicle_id: vehicle.id})
      assert json_response(conn, 200)["data"]["status"] == "accepted"

      # 3. Iniciar (Motorista)
      conn = post(d_conn, ~p"/api/v1/rides/#{ride_id}/start")
      assert json_response(conn, 200)["data"]["status"] == "in_progress"

      # 4. Finalizar (Motorista)
      conn = post(d_conn, ~p"/api/v1/rides/#{ride_id}/complete", %{final_price: 42.0})
      response = json_response(conn, 200)["data"]
      assert response["status"] == "finished"
      assert response["final_price"] == "42.0"
    end
  end

  describe "Regras de Segurança e Erros" do
    test "passageiro não pode aceitar corrida", %{passenger_conn: p_conn, vehicle: vehicle} do
      # Cria uma corrida
      ride = ride_fixture(%{status: :requested})

      # Passageiro tenta aceitar (rota proibida para role: user)
      conn = post(p_conn, ~p"/api/v1/rides/#{ride.id}/accept", %{vehicle_id: vehicle.id})

      assert json_response(conn, 403) # Forbidden
    end

    test "motorista não pode aceitar com veículo de outro", %{driver_conn: d_conn} do
      # Cria outro motorista e outro veículo
      other_driver = driver_fixture()
      other_vehicle = vehicle_fixture(%{driver_id: other_driver.id})

      ride = ride_fixture(%{status: :requested})

      # Motorista logado tenta usar veículo do "other_driver"
      conn = post(d_conn, ~p"/api/v1/rides/#{ride.id}/accept", %{vehicle_id: other_vehicle.id})

      assert json_response(conn, 403)
      assert json_response(conn, 403)["error"] =~ "veículo não pertence"
    end

    test "ninguém pode cancelar corrida finalizada", %{driver_conn: d_conn} do
      # Cria uma corrida já finalizada
      ride = ride_fixture(%{status: :finished})

      conn = post(d_conn, ~p"/api/v1/rides/#{ride.id}/cancel", %{reason: "Teste"})

      # Operations retorna erro de negócio, Controller retorna 409 Conflict ou 403
      assert json_response(conn, 403)["error"] # Ou 409, dependendo da sua impl no controller
    end
  end
end
