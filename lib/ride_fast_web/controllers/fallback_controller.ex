defmodule RideFastWeb.FallbackController do
  @moduledoc """
  Translates controller return values to valid Plug.Conn responses.

  For example, if a controller returns `{:error, :not_found}`, this
  module will render a 404 JSON response.
  """
  use RideFastWeb, :controller

  # Trata erro de validação do Ecto (Changeset inválido)
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: RideFastWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # Trata erro 404 (Objeto não encontrado no banco)
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: RideFastWeb.ErrorHTML, json: RideFastWeb.ErrorJSON)
    |> render(:"404")
  end

  # Trata erro genérico de não autorizado
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Unauthorized"})
  end
end
