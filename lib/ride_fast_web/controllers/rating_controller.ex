defmodule RideFastWeb.RatingController do
  use RideFastWeb, :controller

  alias RideFast.Operations
  alias RideFast.Operations.{Rating, Ride}

  action_fallback RideFastWeb.FallbackController

  # POST /api/v1/rides/:id/ratings
  def create(conn, %{"id" => ride_id, "score" => score, "comment" => comment}) do
    user = Guardian.Plug.current_resource(conn)
    ride = Operations.get_ride!(ride_id)

    cond do
      user.role != :user ->
        conn |> put_status(:forbidden) |> json(%{error: "Apenas passageiros podem avaliar motoristas."})

      ride.user_id != user.id ->
        conn |> put_status(:forbidden) |> json(%{error: "Você não participou desta corrida."})

      ride.status != :finished ->
        conn |> put_status(:bad_request) |> json(%{error: "Apenas corridas finalizadas podem ser avaliadas."})

      true ->
        rating_params = %{
          "score" => score,
          "comment" => comment,
          "ride_id" => ride.id,
          "from_user_id" => user.id,
          "to_driver_id" => ride.driver_id
        }

        with {:ok, %Rating{} = rating} <- Operations.create_rating(rating_params) do
          conn
          |> put_status(:created)
          |> render(:show, rating: rating)
        end
    end
  end

  # GET /api/v1/drivers/:driver_id/ratings
  def index_driver(conn, %{"driver_id" => driver_id}) do
    ratings =
      Operations.list_ratings()
      |> Enum.filter(fn r -> to_string(r.to_driver_id) == driver_id end)

    render(conn, :index, ratings: ratings)
  end
end
