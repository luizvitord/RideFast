defmodule RideFastWeb.AuthController do
  use RideFastWeb, :controller

  def ping(conn, _params) do
    conn
    |> render("ack.json", %{success: true, message: "Pong"})
  end
end
