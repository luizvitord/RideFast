defmodule RideFast.Auth.Guardian do
  use Guardian, otp_app: :ride_fast

  alias RideFast.Accounts

  def subject_for_token(%Accounts.User{id: id}, _claims) do
    {:ok, "User:#{id}"}
  end

  def subject_for_token(%Accounts.Driver{id: id}, _claims) do
    {:ok, "Driver:#{id}"}
  end

  def subject_for_token(_, _), do: {:error, :unknown_resource}

  def resource_from_claims(%{"sub" => "User:" <> id}) do
    try do
      case Accounts.get_user!(id) do
        nil -> {:error, :resource_not_found}
        user -> {:ok, user}
      end
    rescue
      Ecto.NoResultsError -> {:error, :resource_not_found}
    end
  end

  def resource_from_claims(%{"sub" => "Driver:" <> id}) do
    try do
      case Accounts.get_driver!(id) do
        nil -> {:error, :resource_not_found}
        driver -> {:ok, driver}
      end
    rescue
      Ecto.NoResultsError -> {:error, :resource_not_found}
    end
  end

  def resource_from_claims(_), do: {:error, :unknown_resource}
end
