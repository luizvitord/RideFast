defmodule RideFastWeb.Router do
  use RideFastWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RideFastWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.Pipeline, module: RideFast.Auth.Guardian,
                               error_handler: RideFastWeb.AuthErrorHandler

    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_nil: false
  end

  pipeline :api_public do
    plug :accepts, ["json"]
  end

  pipeline :admin_check do
    plug RideFastWeb.Plugs.RequireAdmin
  end

  scope "/", RideFastWeb do
    pipe_through :browser
  end

  #rotas protegida
  scope "/api/v1", RideFastWeb do
     pipe_through [:api, :admin_check]

    get "/users", UserController, :index
  end

  #rotas públicas
  scope "/api/v1/auth", RideFastWeb do
    pipe_through :api_public

    get "/ping", AuthController, :ping #testar conexão

    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ride_fast, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RideFastWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
