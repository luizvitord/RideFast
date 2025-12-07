defmodule RideFastWeb.DriverJSON do
  alias RideFast.Accounts.Driver

  @doc """
  Renderiza uma lista de motoristas.
  """
  def index(%{drivers: drivers}) do
    %{data: for(driver <- drivers, do: data(driver))}
  end

  @doc """
  Renderiza um único motorista.
  """
  def show(%{driver: driver}) do
    %{data: data(driver)}
  end

  def data(%Driver{} = driver) do
    %{
      id: driver.id,
      name: driver.name,
      email: driver.email,
      phone: driver.phone,
      status: driver.status,
      role: driver.role,
      inserted_at: driver.inserted_at
    }
  end
end
