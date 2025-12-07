defmodule RideFastWeb.LanguageJSON do
  alias RideFast.Global.Language

  def index(%{languages: languages}) do
    %{data: for(language <- languages, do: data(language))}
  end

  def show(%{language: language}) do
    %{data: data(language)}
  end


  def errors(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  def data(%Language{} = language) do
    %{
      id: language.id,
      name: language.name,
      code: language.code
    }
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
