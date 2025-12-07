defmodule RideFast.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RideFast.Repo

  alias RideFast.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    User
    |> where([u], is_nil(u.deleted_at))
    |> Repo.get(id)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias RideFast.Accounts.Driver

  @doc """
  Returns the list of drivers.

  ## Examples

      iex> list_drivers()
      [%Driver{}, ...]

  """
  def list_drivers do
    Repo.all(Driver)
  end

  @doc """
  Gets a single driver.

  Raises `Ecto.NoResultsError` if the Driver does not exist.

  ## Examples

      iex> get_driver!(123)
      %Driver{}

      iex> get_driver!(456)
      ** (Ecto.NoResultsError)

  """
  def get_driver!(id), do: Repo.get!(Driver, id)

  @doc """
  Creates a driver.

  ## Examples

      iex> create_driver(%{field: value})
      {:ok, %Driver{}}

      iex> create_driver(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_driver(attrs) do
    %Driver{}
    |> Driver.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a driver.

  ## Examples

      iex> update_driver(driver, %{field: new_value})
      {:ok, %Driver{}}

      iex> update_driver(driver, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_driver(%Driver{} = driver, attrs) do
    driver
    |> Driver.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a driver.

  ## Examples

      iex> delete_driver(driver)
      {:ok, %Driver{}}

      iex> delete_driver(driver)
      {:error, %Ecto.Changeset{}}

  """
  def delete_driver(%Driver{} = driver) do
    Repo.delete(driver)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking driver changes.

  ## Examples

      iex> change_driver(driver)
      %Ecto.Changeset{data: %Driver{}}

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
    Repo.get_by(User, email: email)
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

end
