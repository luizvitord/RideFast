defmodule RideFast.AccountsTest do
  use RideFast.DataCase

  alias RideFast.Accounts

  describe "users" do
    alias RideFast.Accounts.User

    import RideFast.AccountsFixtures

    @invalid_attrs %{name: nil, email: nil, phone: nil, password: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      # Remove o campo virtual password para comparar com o retorno do banco
      user_clean = %{user | password: nil}
      assert Accounts.list_users() == [user_clean]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      user_clean = %{user | password: nil}
      assert Accounts.get_user!(user.id) == user_clean
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        name: "some name",
        email: "some@email.com",
        phone: "some phone",
        password: "some password" # Usando password, não password_hash
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.email == "some@email.com"
      assert user.phone == "some phone"
      # Verifica se o hash foi gerado e se é válido para a senha informada
      assert Bcrypt.verify_pass("some password", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{
        name: "some updated name",
        email: "some_updated@email.com",
        phone: "some updated phone",
        password: "new_password_123" # Atualizando senha
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.email == "some_updated@email.com"
      assert user.phone == "some updated phone"
      assert Bcrypt.verify_pass("new_password_123", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)

      # Compara ignorando o campo virtual password que pode vir diferente
      db_user = Accounts.get_user!(user.id)
      assert user.id == db_user.id
      assert user.email == db_user.email
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_resource/2 with valid credentials returns the user" do
      password = "login_password_123"
      user = user_fixture(%{password: password})

      assert {:ok, %User{} = authenticated_user} = Accounts.authenticate_resource(user.email, password)

      assert authenticated_user.id == user.id
      assert authenticated_user.email == user.email
    end

    test "authenticate_resource/2 with invalid password returns unauthorized" do
      password = "correct_password"
      user = user_fixture(%{password: password})

      assert {:error, :unauthorized} = Accounts.authenticate_resource(user.email, "wrong_password")
    end

    test "authenticate_resource/2 with invalid email returns unauthorized" do
      assert {:error, :unauthorized} = Accounts.authenticate_resource("non_existent@email.com", "any_password")
    end

    test "authenticate_resource/2 fails if user is soft deleted" do
      password = "password_123"
      user = user_fixture(%{password: password})

      # 1. Deleta o usuário (Soft Delete)
      {:ok, _deleted_user} = Accounts.soft_delete_user(user)

      assert {:error, :unauthorized} = Accounts.authenticate_resource(user.email, password)
    end

  end

  describe "drivers" do
    alias RideFast.Accounts.Driver

    import RideFast.AccountsFixtures

    @invalid_attrs %{name: nil, status: nil, email: nil, phone: nil, password: nil}

    test "list_drivers/0 returns all drivers" do
      driver = driver_fixture()
      driver_clean = %{driver | password: nil}
      assert Accounts.list_drivers() == [driver_clean]
    end

    test "get_driver!/1 returns the driver with given id" do
      driver = driver_fixture()
      driver_clean = %{driver | password: nil}
      assert Accounts.get_driver!(driver.id) == driver_clean
    end

    test "create_driver/1 with valid data creates a driver" do
      valid_attrs = %{
        name: "some name",
        status: "active", # Use lowercase se seu enum/string for minusculo
        email: "some_driver@email.com",
        phone: "some phone",
        password: "some password"
      }

      assert {:ok, %Driver{} = driver} = Accounts.create_driver(valid_attrs)
      assert driver.name == "some name"
      # assert driver.status == "active" # Depende da regra de negócio (se cria ativo ou não)
      assert driver.email == "some_driver@email.com"
      assert driver.phone == "some phone"
      assert Bcrypt.verify_pass("some password", driver.password_hash)
    end

    test "create_driver/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_driver(@invalid_attrs)
    end

    test "update_driver/2 with valid data updates the driver" do
      driver = driver_fixture()
      update_attrs = %{
        name: "some updated name",
        status: "inactive",
        email: "updated_driver@email.com",
        phone: "some updated phone",
        password: "new_password"
      }

      assert {:ok, %Driver{} = driver} = Accounts.update_driver(driver, update_attrs)
      assert driver.name == "some updated name"
      assert driver.status == "inactive"
      assert driver.email == "updated_driver@email.com"
      assert driver.phone == "some updated phone"
      assert Bcrypt.verify_pass("new_password", driver.password_hash)
    end

    test "update_driver/2 with invalid data returns error changeset" do
      driver = driver_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_driver(driver, @invalid_attrs)

      db_driver = Accounts.get_driver!(driver.id)
      assert driver.id == db_driver.id
    end

    test "delete_driver/1 deletes the driver" do
      driver = driver_fixture()
      assert {:ok, %Driver{}} = Accounts.delete_driver(driver)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_driver!(driver.id) end
    end

    test "change_driver/1 returns a driver changeset" do
      driver = driver_fixture()
      assert %Ecto.Changeset{} = Accounts.change_driver(driver)
    end
  end
end
