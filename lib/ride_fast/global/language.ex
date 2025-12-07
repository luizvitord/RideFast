defmodule RideFast.Global.Language do
  use Ecto.Schema
  import Ecto.Changeset

  schema "languages" do
    field :code, :string
    field :name, :string

    many_to_many :drivers, RideFast.Accounts.Driver, join_through: RideFast.Global.DriverLanguage

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
  end
end
