defmodule RideFastWeb.DriverProfileJSON do
  alias RideFast.Accounts.DriverProfile

  def show(%{profile: profile}) do
    %{data: data(profile)}
  end

  def data(%DriverProfile{} = profile) do
    %{
      driver_id: profile.driver_id,
      license_number: profile.license_number,
      license_expiry: profile.license_expiry,
      background_check_ok: profile.background_check_ok,
      inserted_at: profile.inserted_at
    }
  end
end
