defmodule RideFast.FleetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RideFast.Fleet` context.
  """

  # Importamos para poder criar um driver se não for passado
  import RideFast.AccountsFixtures

  @doc """
  Generate a vehicle.
  """
  def vehicle_fixture(attrs \\ %{}) do
    # Se não passar driver_id, cria um motorista novo na hora
    driver_id = attrs[:driver_id] || driver_fixture().id

    {:ok, vehicle} =
      attrs
      |> Enum.into(%{
        active: true,
        color: "some color",
        model: "some model",
        plate: "ABC-#{System.unique_integer([:positive])}", # Placa única para evitar erro
        seats: 4,
        driver_id: driver_id # <--- Campo obrigatório adicionado
      })
      |> RideFast.Fleet.create_vehicle()

    vehicle
  end
end
