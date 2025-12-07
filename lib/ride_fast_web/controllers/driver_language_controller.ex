defmodule RideFastWeb.DriverLanguageController do
  use RideFastWeb, :controller

  def index(conn, _params), do: json(conn, %{message: "Idiomas do motorista - A implementar"})
  def create(conn, _params), do: json(conn, %{message: "Adicionar idioma - A implementar"})
  def delete(conn, _params), do: json(conn, %{message: "Remover idioma - A implementar"})
end
