defmodule RideFastWeb.UserJSON do
  alias RideFast.Accounts.User

  def index(%{page: page}) do
    %{
      data: for(user <- page.entries, do: data(user)),
      meta: %{
        page: page.page_number,
        size: page.page_size,
        total_entries: page.total_entries,
        total_pages: page.total_pages
      }
    }
  end

  def data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      inserted_at: user.inserted_at
    }
  end
end
