defmodule RideFastWeb.DriverLanguageController do
  use RideFastWeb, :controller
  alias RideFast.Accounts

  def index(conn, %{"driver_id" => driver_id}) do

    languages = Accounts.list_driver_languages(driver_id)

    conn
    |> put_view(RideFastWeb.LanguageJSON)
    |> render(:index, languages: languages)
  end
  def create(conn, %{"driver_id" => driver_id, "language_id" => language_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    is_owner = match?(%RideFast.Accounts.Driver{}, current_user) and to_string(current_user.id) == driver_id
    is_admin = match?(%RideFast.Accounts.User{}, current_user) and current_user.role == :admin

    unless is_owner or is_admin do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado."})
      |> halt()
    else
      case Accounts.add_language_to_driver(driver_id, language_id) do
        {:ok, _driver} ->
          conn
          |> put_status(:created)
          |> json(%{message: "Idioma associado com sucesso!"})

        {:error, :conflict} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "O motorista já possui este idioma associado."})
      end
    end
  end

  def delete(conn, %{"driver_id" => driver_id, "language_id" => language_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    is_owner = match?(%RideFast.Accounts.Driver{}, current_user) and to_string(current_user.id) == driver_id
    is_admin = match?(%RideFast.Accounts.User{}, current_user) and current_user.role == :admin

    unless is_owner or is_admin do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado."})
      |> halt()
    else
      case Accounts.remove_language_from_driver(driver_id, language_id) do
        {:ok, _driver} ->
          conn
          |> send_resp(:no_content, "")

        {:error, :not_found} ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "O motorista não possui este idioma associado."})
      end
    end
  end
end
