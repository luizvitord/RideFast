defmodule RideFastWeb.RideController do
  use RideFastWeb, :controller

  alias RideFast.Operations
  alias RideFast.Operations.Ride
  alias RideFast.Fleet

  action_fallback RideFastWeb.FallbackController

  # POST /api/v1/rides (Solicitar Corrida)
  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    if user.role == :user do
      # Converte o formato aninhado do JSON para o plano do banco
      ride_params = %{
        "origin_lat" => get_in(params, ["origin", "lat"]),
        "origin_lng" => get_in(params, ["origin", "lng"]),
        "dest_lat" => get_in(params, ["destination", "lat"]),
        "dest_lng" => get_in(params, ["destination", "lng"]),
        "price_estimate" => 25.00, # Valor fixo/mockado para o trabalho
        "requested_at" => NaiveDateTime.utc_now(),
        "status" => :requested,
        "user_id" => user.id
      }

      with {:ok, %Ride{} = ride} <- Operations.create_ride(ride_params) do
        conn
        |> put_status(:created)
        |> render(:show, ride: ride)
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Apenas passageiros podem solicitar corridas."})
    end
  end

  # GET /api/v1/rides (Listar)
  def index(conn, _params) do
    rides = Operations.list_rides()
    render(conn, :index, rides: rides)
  end

  # GET /api/v1/rides/:id (Detalhes)
  def show(conn, %{"id" => id}) do
    ride = Operations.get_ride!(id)
    render(conn, :show, ride: ride)
  end

  # POST /api/v1/rides/:id/accept (Aceitar)
  def accept(conn, %{"id" => id, "vehicle_id" => vehicle_id}) do
    driver = Guardian.Plug.current_resource(conn)

    if driver.role == :driver do
      # Verifica se o veículo pertence ao motorista
      vehicle = Fleet.get_vehicle!(vehicle_id)

      if to_string(vehicle.driver_id) == to_string(driver.id) do
        # Chama a função transacional que você criou
        case Operations.accept_ride(id, driver.id, vehicle_id) do
          {:ok, ride} ->
            render(conn, :show, ride: ride)
          {:error, reason} ->
            conn |> put_status(:conflict) |> json(%{error: reason})
        end
      else
        conn |> put_status(:forbidden) |> json(%{error: "Este veículo não pertence a você."})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Apenas motoristas podem aceitar corridas."})
    end
  end

  # POST /api/v1/rides/:id/start (Iniciar)
  def start(conn, %{"id" => id}) do
    ride = Operations.get_ride!(id)
    driver = Guardian.Plug.current_resource(conn)

    # Só o motorista vinculado pode iniciar
    if is_assigned_driver?(ride, driver) do
      case Operations.start_ride(ride) do
        {:ok, ride} -> render(conn, :show, ride: ride)
        {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Você não é o motorista desta corrida."})
    end
  end

  # POST /api/v1/rides/:id/complete (Finalizar)
  def complete(conn, %{"id" => id, "final_price" => final_price}) do
    ride = Operations.get_ride!(id)
    driver = Guardian.Plug.current_resource(conn)

    if is_assigned_driver?(ride, driver) do
      case Operations.complete_ride(ride, final_price) do
        {:ok, ride} -> render(conn, :show, ride: ride)
        {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Acesso negado."})
    end
  end

  # POST /api/v1/rides/:id/cancel (Cancelar)
  def cancel(conn, %{"id" => id}) do
    ride = Operations.get_ride!(id)
    user = Guardian.Plug.current_resource(conn)

    if can_cancel?(ride, user) do
      case Operations.cancel_ride(ride) do
        {:ok, ride} -> render(conn, :show, ride: ride)
        {:error, reason} -> conn |> put_status(:conflict) |> json(%{error: reason})
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Você não tem permissão para cancelar esta corrida."})
    end
  end

  # DELETE /api/v1/rides/:id (Admin apenas)
  def delete(conn, %{"id" => id}) do
    ride = Operations.get_ride!(id)
    # A rota já é protegida para admin no router, mas por segurança extra:
    with {:ok, %Ride{}} <- Operations.delete_ride(ride) do
      send_resp(conn, :no_content, "")
    end
  end

  def history(conn, _params), do: json(conn, %{message: "Histórico não implementado (Opcional no PDF)"})

  # --- Helpers ---

  defp is_assigned_driver?(ride, user) do
    user.role == :driver and ride.driver_id == user.id
  end

  defp can_cancel?(ride, user) do
    is_admin = user.role == :admin
    is_owner = ride.user_id == user.id
    is_driver = ride.driver_id == user.id

    is_admin or is_owner or is_driver
  end
end
