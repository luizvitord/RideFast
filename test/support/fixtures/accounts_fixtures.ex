defmodule RideFast.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RideFast.Accounts` context.
  """

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        name: "Some User",
        password: "secret_password_123", # <--- Mudou de password_hash para password
        phone: "85999998888"
      })
      |> RideFast.Accounts.create_user()

    user
  end

  @doc """
  Generate a unique driver email.
  """
  def unique_driver_email, do: "driver#{System.unique_integer([:positive])}@example.com"

  @doc """
  Generate a driver.
  """
  def driver_fixture(attrs \\ %{}) do
    {:ok, driver} =
      attrs
      |> Enum.into(%{
        email: unique_driver_email(),
        name: "Some Driver",
        password: "secret_password_123", # <--- Mudou de password_hash para password
        phone: "85999997777",
        status: "active"
      })
      |> RideFast.Accounts.create_driver()

    driver
  end
end
