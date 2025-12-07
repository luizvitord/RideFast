defmodule RideFastWeb.RatingJSON do
  alias RideFast.Operations.Rating

  def index(%{ratings: ratings}) do
    %{data: for(rating <- ratings, do: data(rating))}
  end

  def show(%{rating: rating}) do
    %{data: data(rating)}
  end

  def data(%Rating{} = rating) do
    %{
      id: rating.id,
      score: rating.score,
      comment: rating.comment,
      ride_id: rating.ride_id,
      from_user_id: rating.from_user_id,
      to_driver_id: rating.to_driver_id,
      created_at: rating.inserted_at
    }
  end
end
