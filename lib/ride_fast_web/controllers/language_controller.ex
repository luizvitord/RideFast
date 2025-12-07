defmodule RideFastWeb.LanguageController do
  use RideFastWeb, :controller

  def index(conn, _params), do: json(conn, %{message: "Listar idiomas - A implementar"})
  def create(conn, _params), do: json(conn, %{message: "Criar idioma - A implementar"})
end
