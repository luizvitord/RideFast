defmodule RideFastWeb.DriverLanguageControllerTest do
  use RideFastWeb.ConnCase

  import RideFast.GlobalFixtures
  import RideFast.AccountsFixtures
  alias RideFast.Accounts

  setup %{conn: conn} do
    # Atores do teste
    driver = driver_fixture() # Motorista dono da conta
    other_driver = driver_fixture() # Outro motorista (para testar segurança)

    # Recurso
    language = language_fixture() # Um idioma criado

    %{conn: conn, driver: driver, other_driver: other_driver, language: language}
  end

  defp authed_conn(conn, resource) do
    {:ok, token, _} = RideFast.Auth.Guardian.encode_and_sign(resource)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  describe "POST /drivers/:id/languages/:id (Associate)" do
    test "associates language when driver is owner", %{conn: conn, driver: driver, language: language} do
      conn = authed_conn(conn, driver)
      conn = post(conn, ~p"/api/v1/drivers/#{driver.id}/languages/#{language.id}")

      assert json_response(conn, 201)["message"] =~ "sucesso"

      # Verifica no banco se realmente associou
      langs = Accounts.list_driver_languages(driver.id)
      assert length(langs) == 1
    end

    test "returns 409 Conflict if already associated", %{conn: conn, driver: driver, language: language} do
      # 1. Associa manualmente primeiro
      Accounts.add_language_to_driver(driver.id, language.id)

      # 2. Tenta associar de novo via API
      conn = authed_conn(conn, driver)
      conn = post(conn, ~p"/api/v1/drivers/#{driver.id}/languages/#{language.id}")

      assert json_response(conn, 409)["error"] =~ "já possui"
    end

    test "returns 403 forbidden if trying to change another driver", %{conn: conn, other_driver: other_driver, driver: target_driver, language: language} do
      # 'other_driver' tenta adicionar idioma para 'target_driver'
      conn = authed_conn(conn, other_driver)
      conn = post(conn, ~p"/api/v1/drivers/#{target_driver.id}/languages/#{language.id}")

      assert json_response(conn, 403)
    end
  end

  describe "GET /drivers/:id/languages (List)" do
    test "lists languages for a driver", %{conn: conn, driver: driver, language: language} do
      # Associa
      Accounts.add_language_to_driver(driver.id, language.id)

      # Busca
      conn = authed_conn(conn, driver)
      conn = get(conn, ~p"/api/v1/drivers/#{driver.id}/languages")

      data = json_response(conn, 200)["data"]
      assert length(data) == 1
      assert hd(data)["code"] == language.code
    end
  end

  describe "DELETE /drivers/:id/languages/:id (Remove)" do
    test "removes association", %{conn: conn, driver: driver, language: language} do
      # Associa primeiro
      Accounts.add_language_to_driver(driver.id, language.id)

      # Deleta via API
      conn = authed_conn(conn, driver)
      conn = delete(conn, ~p"/api/v1/drivers/#{driver.id}/languages/#{language.id}")

      assert response(conn, 204) # No Content

      # Garante que sumiu do banco
      langs = Accounts.list_driver_languages(driver.id)
      assert langs == []
    end

    test "returns 404 if association does not exist", %{conn: conn, driver: driver, language: language} do
      conn = authed_conn(conn, driver)
      conn = delete(conn, ~p"/api/v1/drivers/#{driver.id}/languages/#{language.id}")

      assert json_response(conn, 404)
    end
  end
end
