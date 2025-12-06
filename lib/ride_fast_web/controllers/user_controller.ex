defmodule RideFastWeb.UserController do
  use RideFastWeb, :controller
  alias RideFast.Accounts

  def index(conn, params) do
    page = Accounts.list_users(params)

    render(conn, :index, page: page)
  end
end
