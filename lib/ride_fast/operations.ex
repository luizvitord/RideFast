defmodule RideFast.Operations do
  @moduledoc """
  The Operations context.
  """

  import Ecto.Query, warn: false
  alias RideFast.Repo

  alias RideFast.Operations.Ride

  @doc """
  Returns the list of rides.
  """
  def list_rides do
    Ride
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:user, :driver, :vehicle]) # Preload para listar com detalhes
  end

  @doc """
  Gets a single ride.
  """
  def get_ride!(id) do
    Ride
    |> Repo.get!(id)
    |> Repo.preload([:user, :driver, :vehicle]) # Importante para o JSON completo
  end

  @doc """
  Creates a ride (Solicitação).
  """
  def create_ride(attrs) do
    %Ride{}
    |> Ride.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ride (Genérico - usado internamente ou por admins).
  """
  def update_ride(%Ride{} = ride, attrs) do
    ride
    |> Ride.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ride.
  """
  def delete_ride(%Ride{} = ride) do
    Repo.delete(ride)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ride changes.
  """
  def change_ride(%Ride{} = ride, attrs \\ %{}) do
    Ride.changeset(ride, attrs)
  end

  # --- MÁQUINA DE ESTADOS E REGRAS DE NEGÓCIO (NOVO) ---

  @doc """
  Aceita uma corrida de forma transacional.
  Bloqueia a linha no banco (lock) para garantir que apenas um motorista consiga.
  """
  def accept_ride(ride_id, driver_id, vehicle_id) do
    Repo.transaction(fn ->
      # Trava a linha para evitar Race Condition (Dois motoristas aceitando ao mesmo tempo)
      # Requer que o banco suporte locking (MySQL/Postgres suportam)
      ride = Repo.get(Ride, ride_id, lock: "FOR UPDATE")

      cond do
        is_nil(ride) ->
          Repo.rollback("Corrida não encontrada.")

        ride.status != :requested ->
          Repo.rollback("Esta corrida não está mais disponível (Status atual: #{ride.status})")

        true ->
          ride
          |> Ride.changeset(%{
            status: :accepted,
            driver_id: driver_id,
            vehicle_id: vehicle_id
          })
          |> Repo.update!()
          |> Repo.preload([:user, :driver, :vehicle]) # Retorna completo
      end
    end)
  end

  @doc """
  Inicia a corrida (Muda status para in_progress).
  """
  def start_ride(%Ride{} = ride) do
    if ride.status == :accepted do
      ride
      |> Ride.changeset(%{
        status: :in_progress,
        started_at: NaiveDateTime.utc_now()
      })
      |> Repo.update()
    else
      {:error, "A corrida precisa estar ACEITA para ser iniciada."}
    end
  end

  @doc """
  Finaliza a corrida (Muda status para finished e define preço final).
  """
  def complete_ride(%Ride{} = ride, final_price) do
    if ride.status == :in_progress do
      ride
      |> Ride.changeset(%{
        status: :finished,
        ended_at: NaiveDateTime.utc_now(),
        final_price: final_price
      })
      |> Repo.update()
    else
      {:error, "A corrida precisa estar EM ANDAMENTO para ser finalizada."}
    end
  end

  @doc """
  Cancela a corrida (Muda status para canceled).
  """
  def cancel_ride(%Ride{} = ride) do
    if ride.status in [:requested, :accepted] do
      ride
      |> Ride.changeset(%{status: :canceled})
      |> Repo.update()
    else
      {:error, "Não é possível cancelar uma corrida que já começou ou finalizou."}
    end
  end

  # --- RATINGS (Mantido do original) ---

  alias RideFast.Operations.Rating

  def list_ratings do
    Repo.all(Rating)
  end

  def get_rating!(id), do: Repo.get!(Rating, id)

  def create_rating(attrs) do
    %Rating{}
    |> Rating.changeset(attrs)
    |> Repo.insert()
  end

  def update_rating(%Rating{} = rating, attrs) do
    rating
    |> Rating.changeset(attrs)
    |> Repo.update()
  end

  def delete_rating(%Rating{} = rating) do
    Repo.delete(rating)
  end

  def change_rating(%Rating{} = rating, attrs \\ %{}) do
    Rating.changeset(rating, attrs)
  end
end
