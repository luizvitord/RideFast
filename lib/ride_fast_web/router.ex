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
    get "/", PageController, :home
  end

  # ROTAS PÚBLICAS
  scope "/api/v1/auth", RideFastWeb do
    pipe_through :api_public

    get "/ping", AuthController, :ping
    post "/register", AuthController, :register
    post "/login", AuthController, :login


  #ROTA PÚBLICA - LANGUAGE
  end
  scope "/api/v1", RideFastWeb do
    pipe_through :api_public

    get "/languages", LanguageController, :index
  end

  # ROTAS ADMIN
  scope "/api/v1", RideFastWeb do
    pipe_through [:api, :admin_check]

    get "/users", UserController, :index
    post "/drivers", DriverController, :create
    delete "/drivers/:id", DriverController, :delete
    post "/languages", LanguageController, :create
  end

  # ROTAS PROTEGIDAS
  scope "/api/v1", RideFastWeb do
    pipe_through [:api]

    # Users:
    resources "/users", UserController, only: [:show, :update, :delete]

    # Drivers
    resources "/drivers", DriverController, only: [:index, :show, :update]

    # Driver Profile
    get "/drivers/:driver_id/profile", DriverProfileController, :show
    post "/drivers/:driver_id/profile", DriverProfileController, :create
    put "/drivers/:driver_id/profile", DriverProfileController, :update

    # Vehicles
    get "/drivers/:driver_id/vehicles", VehicleController, :index
    post "/drivers/:driver_id/vehicles", VehicleController, :create
    put "/vehicles/:id", VehicleController, :update
    delete "/vehicles/:id", VehicleController, :delete

    # Languages
    post "/languages", LanguageController, :create

    # Driver Languages
    get "/drivers/:driver_id/languages", DriverLanguageController, :index
    post "/drivers/:driver_id/languages/:language_id", DriverLanguageController, :create
    delete "/drivers/:driver_id/languages/:language_id", DriverLanguageController, :delete
    # Rides
    post "/rides", RideController, :create
    get "/rides", RideController, :index
    get "/rides/:id", RideController, :show
    delete "/rides/:id", RideController, :delete

    # Ações da Máquina de Estados
    post "/rides/:id/accept", RideController, :accept
    post "/rides/:id/start", RideController, :start
    post "/rides/:id/complete", RideController, :complete
    post "/rides/:id/cancel", RideController, :cancel
    get "/rides/:id/history", RideController, :history

    # Ratings
    post "/rides/:id/ratings", RatingController, :create
    get "/drivers/:driver_id/ratings", RatingController, :index_driver
  end

  if Application.compile_env(:ride_fast, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: RideFastWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
