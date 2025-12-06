defmodule RideFastWeb.Plugs.RequireAdmin do
  import Plug.Conn
  alias RideFast.Accounts.User

  def init(options), do: options

  def call(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)

    case current_user do
      %User{role: :admin} ->
        conn

      _ ->
        conn
        |> put_status(:forbidden)
        |> Phoenix.Controller.json(%{error: "Acesso negado. Requer privilégios de administrador."})
        |> halt()
    end
  end
end
