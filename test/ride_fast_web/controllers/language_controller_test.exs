defmodule RideFastWeb.LanguageControllerTest do
  use RideFastWeb.ConnCase

  import RideFast.GlobalFixtures
  import RideFast.AccountsFixtures
  alias RideFast.Accounts

  # Atributos válidos para criar um idioma
  @create_attrs %{code: "FR", name: "French"}
  @invalid_attrs %{code: nil, name: nil}

  setup %{conn: conn} do
    # Cria um Admin para testar a rota POST protegida
    {:ok, admin} = Accounts.create_admin(%{
      name: "Admin", email: "admin@test.com", password: "123", phone: "0000"
    })

    # Cria um passageiro comum para testar acesso negado
    user = user_fixture()

    %{conn: conn, admin: admin, user: user}
  end

  # Helper para autenticar no teste
  defp authed_conn(conn, resource) do
    {:ok, token, _} = RideFast.Auth.Guardian.encode_and_sign(resource)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  describe "GET /api/v1/languages" do
    test "lists all languages (public access)", %{conn: conn} do
      # Cria um idioma no banco
      language_fixture()

      conn = get(conn, ~p"/api/v1/languages")

      # Verifica se retornou 200 e se a lista não está vazia
      assert json_response(conn, 200)["data"] != []
    end
  end

  describe "POST /api/v1/languages" do
    test "creates language when user is admin", %{conn: conn, admin: admin} do
      conn = authed_conn(conn, admin)
      conn = post(conn, ~p"/api/v1/languages", @create_attrs)

      assert %{"id" => _id} = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, admin: admin} do
      conn = authed_conn(conn, admin)
      conn = post(conn, ~p"/api/v1/languages", @invalid_attrs)

      # Espera 400 Bad Request
      assert json_response(conn, 400)["errors"] != %{}
    end

    test "returns 403 forbidden when regular user tries to create", %{conn: conn, user: user} do
      conn = authed_conn(conn, user)
      conn = post(conn, ~p"/api/v1/languages", @create_attrs)

      assert json_response(conn, 403)
    end
  end
end
