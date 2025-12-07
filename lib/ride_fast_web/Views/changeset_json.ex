defmodule RideFastWeb.ChangesetJSON do
  @doc """
  Renders changeset errors.
  """
  def error(%{changeset: changeset}) do
    # Quando usamos o Ecto.Changeset.traverse_errors, ele nos dá um mapa de erros
    # Vamos usar a função translate_error que já existe no CoreComponents ou ErrorHelpers
    # Mas para simplificar JSON, podemos fazer assim:
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)

    %{errors: errors}
  end
end
