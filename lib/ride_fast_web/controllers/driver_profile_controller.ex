defmodule RideFastWeb.DriverProfileController do
  use RideFastWeb, :controller

  def show(conn, _params), do: json(conn, %{message: "Mostrar perfil - A implementar"})
  def create(conn, _params), do: json(conn, %{message: "Criar perfil - A implementar"})
  def update(conn, _params), do: json(conn, %{message: "Atualizar perfil - A implementar"})
end
