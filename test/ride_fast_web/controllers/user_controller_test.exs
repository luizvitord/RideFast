defmodule RideFastWeb.UserControllerTest do
  use RideFastWeb.ConnCase

  import RideFast.AccountsFixtures

  # Define atributos válidos para criar um novo usuário via JSON
  @create_attrs %{
    name: "John Doe",
    email: "john@example.com",
    phone: "123456789",
    password: "password123",
    role: "user"
  }

  @driver_attrs %{
    name: "Driver John",
    email: "driver@example.com",
    phone: "987654321",
    password: "password123",
    role: "driver"
  }

  @invalid_attrs %{name: nil, email: nil, password: nil}

  describe "POST /api/v1/auth/register" do
    test "creates user and renders user data when data is valid", %{conn: conn} do
      # Faz a requisição POST para a rota
      conn = post(conn, ~p"/api/v1/auth/register", @create_attrs)

      # Verifica se o status é 201 (Created)
      assert %{"id" => id} = json_response(conn, 201)

      # Opcional: Verificar se o retorno JSON contém os dados esperados
      assert json_response(conn, 201)["email"] == @create_attrs.email
      assert json_response(conn, 201)["role"] == "user"
    end

    test "creates driver when role is driver", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/register", @driver_attrs)

      assert %{"id" => _id} = json_response(conn, 201)
      assert json_response(conn, 201)["role"] == "driver"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/register", @invalid_attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end

    test "renders 409 conflict when email is already taken", %{conn: conn} do
      # 1. Cria um usuário primeiro (usando a fixture ou a API)
      user_fixture(%{email: "duplicate@email.com"})

      # 2. Tenta registrar de novo com o mesmo email
      attrs = Map.put(@create_attrs, :email, "duplicate@email.com")
      conn = post(conn, ~p"/api/v1/auth/register", attrs)

      # Espera erro 409
      assert json_response(conn, 409)["error"] =~ "Email já cadastrado"
    end
  end

  describe "POST /api/v1/auth/login" do
    setup do
      # Cria um usuário no banco antes de cada teste de login
      # A senha na fixture deve ser conhecida para testarmos o login
      password = "secret_password"
      user = user_fixture(%{email: "login@test.com", password: password})

      %{user: user, password: password}
    end

    test "returns token and user data when credentials are valid", %{conn: conn, user: user, password: password} do
      conn = post(conn, ~p"/api/v1/auth/login", %{
        "email" => user.email,
        "password" => password
      })

      # Verifica status 200 OK
      response = json_response(conn, 200)

      # Verifica se o Token veio na resposta
      assert response["token"] != nil
      assert response["user"]["email"] == user.email
    end

    test "returns 401 unauthorized when password is wrong", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/v1/auth/login", %{
        "email" => user.email,
        "password" => "wrong_password"
      })

      assert json_response(conn, 401)["error"] =~ "Email ou senha inválidos"
    end

    test "returns 401 unauthorized when email does not exist", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/login", %{
        "email" => "ghost@user.com",
        "password" => "123456"
      })

      assert json_response(conn, 401)["error"] =~ "Email ou senha inválidos"
    end
  end
end
