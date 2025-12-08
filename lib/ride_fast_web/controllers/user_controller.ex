defmodule RideFastWeb.UserController do
  use RideFastWeb, :controller
  alias RideFast.Accounts

  def index(conn, params) do
    page = Accounts.list_users(params)

    render(conn, :index, page: page)
  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    is_authorized = current_user.role == :admin or to_string(current_user.id) == id

    if is_authorized do
      try do
        user = Accounts.get_user(id)
        render(conn, :show, user: user)
      rescue
        Ecto.NoResultsError ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "Usuário não encontrado."})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado. Você só pode visualizar seu próprio perfil."})
    end
  end

def update(conn, %{"id" => id} = params) do
    current_user = Guardian.Plug.current_resource(conn)

    is_authorized = current_user.role == :admin or to_string(current_user.id) == id

    unless is_authorized do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado. Você só pode editar seu próprio perfil."})
      |> halt()
    end

    case Accounts.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Usuário não encontrado."})

      user ->
        safe_params = Map.drop(params, ["id", "role", "password_hash", "inserted_at", "updated_at"])

        case Accounts.update_user(user, safe_params) do
          {:ok, updated_user} ->
            render(conn, :show, user: updated_user)

          {:error, changeset} ->
            errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
              Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
                opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
              end)
            end)

            conn
            |> put_status(:bad_request)
            |> json(%{error: "Falha na atualização.", details: errors})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    is_authorized = current_user.role == :admin or to_string(current_user.id) == id

    unless is_authorized do
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado."})
      |> halt()
    end

    case Accounts.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Usuário não encontrado."})

      user ->
        {:ok, _struct} = Accounts.soft_delete_user(user)

        conn
        |> send_resp(:no_content, "")
    end
  end

end
