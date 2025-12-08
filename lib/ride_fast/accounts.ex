defmodule RideFast.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RideFast.Repo

  alias RideFast.Accounts.User
  alias RideFast.Global.Language
  alias RideFast.Global
  alias RideFast.Accounts.DriverProfile

  @doc """
  Returns the list of users.
  """
  def list_users do
    User
    |> where([u], is_nil(u.deleted_at))
    |> Repo.all()
  end

  @doc """
  Gets a single user.
  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id) do
    User
    |> where([u], is_nil(u.deleted_at))
    |> Repo.get!(id)
  end

  #Função sem bang
  def get_user(id) do
    User
    |> where([u], is_nil(u.deleted_at)) # Mantém a regra do Soft Delete
    |> Repo.get(id) # <--- Note: Repo.get (sem exclamação)
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user (Soft Delete).
  """
  def delete_user(%User{} = user) do
    soft_delete_user(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias RideFast.Accounts.Driver

  @doc """
  Returns the list of drivers.
  """
  def list_drivers do
    Repo.all(Driver)
  end

  @doc """
  Gets a single driver.
  """
  def get_driver!(id), do: Repo.get!(Driver, id)

  @doc """
  Creates a driver.
  """
  def create_driver(attrs) do
    %Driver{}
    |> Driver.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a driver.
  """
  def update_driver(%Driver{} = driver, attrs) do
    driver
    |> Driver.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a driver.
  """
  def delete_driver(%Driver{} = driver) do
    Repo.delete(driver)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking driver changes.
  """
  def change_driver(%Driver{} = driver, attrs \\ %{}) do
    Driver.changeset(driver, attrs)
  end

  def register_member(%{"role" => "driver"} = attrs) do
    create_driver(attrs)
  end

  def register_member(%{"role" => "user"} = attrs) do
    create_user(attrs)
  end

  def register_member(_attrs), do: {:error, :invalid_role}

  def create_admin(attrs) do
    %User{}
    |> User.admin_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email(email) do
    User
    |> where([u], is_nil(u.deleted_at))
    |> Repo.get_by(email: email)
  end

  def get_driver_by_email(email) do
    Repo.get_by(Driver, email: email)
  end

  def authenticate_resource(email, password) do
    user = get_user_by_email(email)
    resource = user || get_driver_by_email(email)

    cond do
      resource && Bcrypt.verify_pass(password, resource.password_hash) ->
        {:ok, resource}
      resource ->
        {:error, :unauthorized}
      true ->
        Bcrypt.no_user_verify()
        {:error, :unauthorized}
    end
  end

  def list_users(params) do
    search_term = params["q"]
    page = String.to_integer(params["page"] || "1")
    size = String.to_integer(params["size"] || "10")
    offset = (page - 1) * size

    query = from u in User,
      where: u.role == :user,
      where: is_nil(u.deleted_at)

    query =
      if search_term && search_term != "" do
        search_pattern = "%#{search_term}%"
        from u in query,
          where: like(u.name, ^search_pattern) or like(u.email, ^search_pattern)
      else
        query
      end

    total_entries = Repo.aggregate(query, :count, :id)

    entries =
      query
      |> limit(^size)
      |> offset(^offset)
      |> order_by(desc: :inserted_at)
      |> Repo.all()

    %{
      entries: entries,
      page_number: page,
      page_size: size,
      total_entries: total_entries,
      total_pages: ceil(total_entries / size)
    }
  end

  def soft_delete_user(%User{} = user) do
    now = NaiveDateTime.utc_now()
    truncated_now = NaiveDateTime.truncate(now, :second)

    user
    |> Ecto.Changeset.change(deleted_at: truncated_now)
    |> Repo.update()
  end

  # --- Funções de Profile e Idiomas ---

  def get_driver_profile_by_driver_id(driver_id) do
    Repo.get_by(DriverProfile, driver_id: driver_id)
  end

  def create_driver_profile(attrs) do
    %DriverProfile{}
    |> DriverProfile.changeset(attrs)
    |> Repo.insert()
  end

  def update_driver_profile(%DriverProfile{} = profile, attrs) do
    profile
    |> DriverProfile.changeset(attrs)
    |> Repo.update()
  end

  def add_language_to_driver(driver_id, language_id) do
    driver = Repo.get!(Driver, driver_id) |> Repo.preload(:languages)
    language = Repo.get!(Language, language_id)

    already_has? = Enum.any?(driver.languages, fn l -> l.id == language.id end)

    if already_has? do
      {:error, :conflict}
    else
      driver
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:languages, [language | driver.languages])
      |> Repo.update()
    end
  end

  def list_driver_languages(driver_id) do
    driver = Repo.get!(Driver, driver_id)
    driver = Repo.preload(driver, :languages)
    driver.languages
  end

  def remove_language_from_driver(driver_id, language_id) do
    driver = Repo.get!(Driver, driver_id) |> Repo.preload(:languages)
    target_id = String.to_integer(language_id)

    exists? = Enum.any?(driver.languages, fn l -> l.id == target_id end)

    if exists? do
      new_languages = Enum.reject(driver.languages, fn l -> l.id == target_id end)

      driver
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:languages, new_languages)
      |> Repo.update()
    else
      {:error, :not_found}
    end
  end
end
