defmodule RideFastWeb.RideController do
  use RideFastWeb, :controller

  def index(conn, _params), do: json(conn, %{message: "Listar rides - A implementar"})
  def create(conn, _params), do: json(conn, %{message: "Solicitar ride - A implementar"})
  def show(conn, _params), do: json(conn, %{message: "Mostrar ride - A implementar"})
  def delete(conn, _params), do: json(conn, %{message: "Cancelar ride (delete) - A implementar"})

  # Ações da Máquina de Estados
  def accept(conn, _params), do: json(conn, %{message: "Aceitar ride - A implementar"})
  def start(conn, _params), do: json(conn, %{message: "Iniciar ride - A implementar"})
  def complete(conn, _params), do: json(conn, %{message: "Finalizar ride - A implementar"})
  def cancel(conn, _params), do: json(conn, %{message: "Cancelar ride (action) - A implementar"})
  def history(conn, _params), do: json(conn, %{message: "Histórico ride - A implementar"})
end
