defmodule RideFastWeb.DriverProfileControllerTest do
  use RideFastWeb.ConnCase

  import RideFast.AccountsFixtures
  alias RideFast.Auth.Guardian

  # Função auxiliar para autenticar
  defp authenticated_conn(conn, user) do
    {:ok, token, _} = Guardian.encode_and_sign(user)
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  setup %{conn: conn} do
    driver = driver_fixture()
    other_driver = driver_fixture()

    # Autentica como o "driver" principal
    conn = authenticated_conn(conn, driver)

    %{conn: conn, driver: driver, other_driver: other_driver}
  end

  describe "Driver Profile" do
    test "cria perfil para si mesmo com sucesso", %{conn: conn, driver: driver} do
      params = %{
        "license_number" => "12345678900",
        "license_expiry" => "2030-12-31",
        "background_check_ok" => true
      }

      conn = post(conn, ~p"/api/v1/drivers/#{driver.id}/profile", params)

      assert json_response(conn, 201)["data"]["license_number"] == "12345678900"
      assert json_response(conn, 201)["data"]["driver_id"] == driver.id
    end

    test "atualiza o próprio perfil", %{conn: conn, driver: driver} do
      # 1. Cria o perfil primeiro (USANDO STRING KEYS AGORA)
      params = %{
        "license_number" => "OLD",
        "license_expiry" => "2025-01-01",
        "background_check_ok" => true
      }
      # Injeta driver_id e cria direto no contexto
      RideFast.Accounts.create_driver_profile(Map.put(params, "driver_id", driver.id))

      # 2. Tenta atualizar
      update_params = %{"license_number" => "NEW_CNH_123"}
      conn = put(conn, ~p"/api/v1/drivers/#{driver.id}/profile", update_params)

      assert json_response(conn, 200)["data"]["license_number"] == "NEW_CNH_123"
    end

    test "erro ao tentar criar perfil para outro motorista", %{conn: conn, other_driver: other_driver} do
      params = %{
        "license_number" => "123",
        "license_expiry" => "2030-01-01",
        "background_check_ok" => true
      }

      # Driver logado tenta criar para Other Driver
      conn = post(conn, ~p"/api/v1/drivers/#{other_driver.id}/profile", params)

      assert json_response(conn, 403)["error"] =~ "Acesso negado"
    end

    test "erro ao tentar ver perfil de outro motorista", %{conn: conn, other_driver: other_driver} do
      # Cria perfil do outro
      RideFast.Accounts.create_driver_profile(%{
        "driver_id" => other_driver.id,
        "license_number" => "999",
        "license_expiry" => "2030-01-01",
        "background_check_ok" => true
      })

      # Driver logado tenta ver perfil do Other Driver
      conn = get(conn, ~p"/api/v1/drivers/#{other_driver.id}/profile")

      assert json_response(conn, 403)["error"] =~ "Acesso negado"
    end
  end
end
