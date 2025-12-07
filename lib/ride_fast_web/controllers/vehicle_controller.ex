defmodule RideFastWeb.VehicleController do
  use RideFastWeb, :controller

  alias RideFast.Fleet
  alias RideFast.Fleet.Vehicle

  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/drivers/:driver_id/vehicles
  def index(conn, %{"driver_id" => driver_id}) do
    current_user = Guardian.Plug.current_resource(conn)

    if can_manage?(current_user, driver_id) do
      vehicles =
        Fleet.list_vehicles()
        |> Enum.filter(fn v -> to_string(v.driver_id) == driver_id end)

      render(conn, :index, vehicles: vehicles)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado."})
    end
  end

  # POST /api/v1/drivers/:driver_id/vehicles
  def create(conn, %{"driver_id" => driver_id, "vehicle" => vehicle_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    if can_manage?(current_user, driver_id) do
      vehicle_params = Map.put(vehicle_params, "driver_id", driver_id)

      with {:ok, %Vehicle{} = vehicle} <- Fleet.create_vehicle(vehicle_params) do
        conn
        |> put_status(:created)
        |> render(:show, vehicle: vehicle)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado."})
    end
  end

  # PUT /api/v1/vehicles/:id
  def update(conn, %{"id" => id, "vehicle" => vehicle_params}) do
    vehicle = Fleet.get_vehicle!(id)
    current_user = Guardian.Plug.current_resource(conn)

    if can_manage?(current_user, to_string(vehicle.driver_id)) do
      with {:ok, %Vehicle{} = vehicle} <- Fleet.update_vehicle(vehicle, vehicle_params) do
        render(conn, :show, vehicle: vehicle)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado."})
    end
  end

  # DELETE /api/v1/vehicles/:id
  def delete(conn, %{"id" => id}) do
    vehicle = Fleet.get_vehicle!(id)
    current_user = Guardian.Plug.current_resource(conn)

    if can_manage?(current_user, to_string(vehicle.driver_id)) do
      with {:ok, %Vehicle{}} <- Fleet.delete_vehicle(vehicle) do
        send_resp(conn, :no_content, "")
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado."})
    end
  end

  defp can_manage?(user, target_driver_id) do
    is_admin = user.role == :admin
    is_owner = user.role == :driver and to_string(user.id) == target_driver_id

    is_admin or is_owner
  end
end
