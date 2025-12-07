defmodule RideFast.GlobalFixtures do
  @moduledoc """
  Helpers para testes do contexto Global.
  """

  def unique_language_code, do: "PT-#{System.unique_integer([:positive])}"

  def language_fixture(attrs \\ %{}) do
    # Gera um código único se não for passado um
    attrs = Enum.into(attrs, %{
      code: unique_language_code(),
      name: "Language Name"
    })

    {:ok, language} = RideFast.Global.create_language(attrs)

    language
  end
end
