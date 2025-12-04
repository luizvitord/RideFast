defmodule RideFast.GlobalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RideFast.Global` context.
  """

  @doc """
  Generate a language.
  """
  def language_fixture(attrs \\ %{}) do
    {:ok, language} =
      attrs
      |> Enum.into(%{
        code: "some code",
        name: "some name"
      })
      |> RideFast.Global.create_language()

    language
  end
end
