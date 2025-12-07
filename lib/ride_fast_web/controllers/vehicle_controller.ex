defmodule RideFastWeb.VehicleController do
  use RideFastWeb, :controller

  def index(conn, _params), do: json(conn, %{message: "Listar veículos - A implementar"})
  def create(conn, _params), do: json(conn, %{message: "Criar veículo - A implementar"})
  def update(conn, _params), do: json(conn, %{message: "Atualizar veículo - A implementar"})
  def delete(conn, _params), do: json(conn, %{message: "Deletar veículo - A implementar"})
end
