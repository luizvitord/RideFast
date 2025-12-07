defmodule RideFastWeb.LanguageJSON do
  alias RideFast.Global.Language

  def index(%{languages: languages}) do
    %{data: for(language <- languages, do: data(language))}
  end

def show(%{language: language}) do
    %{data: data(language)}
  end

  def data(%Language{} = language) do
    %{
      id: language.id,
      name: language.name,
      code: language.code
    }
  end
end
