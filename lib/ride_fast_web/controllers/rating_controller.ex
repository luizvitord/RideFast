defmodule RideFastWeb.RatingController do
  use RideFastWeb, :controller

  def create(conn, _params), do: json(conn, %{message: "Avaliar - A implementar"})
  def index_driver(conn, _params), do: json(conn, %{message: "Avaliações do motorista - A implementar"})
end
