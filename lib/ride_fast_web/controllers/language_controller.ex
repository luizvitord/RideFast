defmodule RideFastWeb.LanguageController do
  use RideFastWeb, :controller
  alias RideFast.Global

  def index(conn, _params) do
    languages = Global.list_languages()
    render(conn, :index, languages: languages)
  end

  def create(conn, params) do
    case Global.create_language(params) do
      {:ok, language} ->
        conn
        |> put_status(:created)
        |> render(:show, language: language)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:bad_request)
        |> render(:errors, changeset: changeset)
    end
  end

end
