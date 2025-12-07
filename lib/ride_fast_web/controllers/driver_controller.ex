defmodule RideFastWeb.DriverController do
  use RideFastWeb, :controller

  alias RideFast.Accounts
  alias RideFast.Accounts.Driver

  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/drivers
  def index(conn, _params) do
    drivers = Accounts.list_drivers()
    render(conn, :index, drivers: drivers)
  end

  # POST /api/v1/drivers (Rota de Admin)
  def create(conn, %{"driver" => driver_params}) do
    driver_params = Map.put(driver_params, "role", "driver")

    with {:ok, %Driver{} = driver} <- Accounts.create_driver(driver_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/drivers/#{driver}")
      |> render(:show, driver: driver)
    end
  end

  # GET /api/v1/drivers/:id
  def show(conn, %{"id" => id}) do
    # vai dps carregar Profile, Vehicles e Languages
    driver = Accounts.get_driver!(id)
    render(conn, :show, driver: driver)
  end

  # PUT /api/v1/drivers/:id
  def update(conn, %{"id" => id, "driver" => driver_params}) do
    driver = Accounts.get_driver!(id)
    current_user = Guardian.Plug.current_resource(conn)

    if is_owner_or_admin?(current_user, driver) do
      with {:ok, %Driver{} = driver} <- Accounts.update_driver(driver, driver_params) do
        render(conn, :show, driver: driver)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Você não tem permissão para alterar este perfil."})
    end
  end

  # DELETE /api/v1/drivers/:id
  def delete(conn, %{"id" => id}) do
    driver = Accounts.get_driver!(id)

    with {:ok, %Driver{}} <- Accounts.delete_driver(driver) do
      send_resp(conn, :no_content, "")
    end
  end

  defp is_owner_or_admin?(resource, target_driver) do
    is_admin = Map.get(resource, :role) == :admin
    is_owner = Map.get(resource, :role) == :driver and resource.id == target_driver.id

    is_admin or is_owner
  end
end
