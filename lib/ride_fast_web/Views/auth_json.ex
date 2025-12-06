defmodule RideFastWeb.AuthJSON do
  def render("ack.json", %{success: success, message: message}), do: %{success: success, message: message}
  def ack(%{success: success, message: message}) do
      # O mapa retornado é o que se torna o JSON.
      # Adicione a chave :data ou apenas retorne o mapa simples se preferir.
      %{
        success: success,
        message: message
      }
    end

end
