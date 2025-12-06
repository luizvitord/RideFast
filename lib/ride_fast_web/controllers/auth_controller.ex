defmodule RideFastWeb.AuthController do
  use RideFastWeb, :controller
  alias RideFast.Accounts
  alias RideFast.Auth.Guardian, as: Auth

  def ping(conn, _params) do
    conn
    |> render("ack.json", %{success: true, message: "Pong"})
  end

  def register(conn, params) do
    case Accounts.register_member(params) do
      {:ok, member} ->
        conn
        |> put_status(:created)
        |> json(%{
            success: true,
            message: "#{String.capitalize(to_string(member.role))} criado com sucesso!",
            id: member.id,
            email: member.email,
            role: member.role
          })

      {:error, %Ecto.Changeset{} = changeset} ->
        if changeset.errors[:email] do
          conn
          |> put_status(:conflict)
          |> json(%{error: "Email já cadastrado."})
        else
          errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
              opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
            end)
          end)

          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: errors})
        end

      {:error, :invalid_role} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Dados inválidos"})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
      case Accounts.authenticate_resource(email, password) do
        {:ok, resource} ->

          {:ok, token, _claims} = Auth.encode_and_sign(resource)

          conn
          |> put_status(:ok)
          |> json(%{
            token: token,
            user: %{
              id: resource.id,
              name: resource.name,
              email: resource.email,
              role: resource.role
            }
          })

        {:error, :unauthorized} ->
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Email ou senha inválidos."})
      end
    end

end
