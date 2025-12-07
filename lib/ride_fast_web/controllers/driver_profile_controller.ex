defmodule RideFastWeb.DriverProfileController do
  use RideFastWeb, :controller

  alias RideFast.Accounts
  alias RideFast.Accounts.DriverProfile

  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/drivers/:driver_id/profile
  def show(conn, %{"driver_id" => driver_id}) do
    if can_manage?(conn, driver_id) do
      case Accounts.get_driver_profile_by_driver_id(driver_id) do
        nil -> conn |> put_status(:not_found) |> json(%{error: "Perfil não encontrado"})
        profile -> render(conn, :show, profile: profile)
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Acesso negado"})
    end
  end

  # POST /api/v1/drivers/:driver_id/profile
  def create(conn, %{"driver_id" => driver_id} = params) do
    if can_manage?(conn, driver_id) do
      if Accounts.get_driver_profile_by_driver_id(driver_id) do
        conn |> put_status(:conflict) |> json(%{error: "Perfil já existe para este motorista"})
      else
        profile_params = Map.merge(params, %{"driver_id" => driver_id})
        with {:ok, %DriverProfile{} = profile} <- Accounts.create_driver_profile(profile_params) do
          conn |> put_status(:created) |> render(:show, profile: profile)
        end
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Acesso negado"})
    end
  end

  # PUT /api/v1/drivers/:driver_id/profile
  def update(conn, %{"driver_id" => driver_id} = params) do
    if can_manage?(conn, driver_id) do
      case Accounts.get_driver_profile_by_driver_id(driver_id) do
        nil -> conn |> put_status(:not_found) |> json(%{error: "Perfil não encontrado"})
        profile ->
          with {:ok, %DriverProfile{} = updated_profile} <- Accounts.update_driver_profile(profile, params) do
            render(conn, :show, profile: updated_profile)
          end
      end
    else
      conn |> put_status(:forbidden) |> json(%{error: "Acesso negado"})
    end
  end

  defp can_manage?(conn, target_id) do
    user = Guardian.Plug.current_resource(conn)
    is_admin = user.role == :admin
    is_owner = user.role == :driver and to_string(user.id) == target_id
    is_admin or is_owner
  end
end
