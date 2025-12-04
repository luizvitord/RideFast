defmodule RideFast.Global.DriverLanguage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drivers_languages" do

    field :driver_id, :id
    field :language_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(driver_language, attrs) do
    driver_language
    |> cast(attrs, [])
    |> validate_required([])
  end
end
