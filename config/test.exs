import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ride_fast, RideFast.Repo,
  username: "root",
  password: "LuizVitor@12345",
  hostname: "127.0.0.1",
  database: "ride_fast_test#{System.get_env("MIX_TEST_PARTITION")}",  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ride_fast, RideFastWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "qjI7NRjqjkR4GaqPiX2DdhXqFV1EiUGtuAUNPNX1Ef6EZpfK4IEY+nZsAuOhYExQ",
  server: false

# In test we don't send emails
config :ride_fast, RideFast.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :ride_fast, RideFast.Auth.Guardian,
issuer: "RideFast",
secret_key: "C4crCJFvKwY1UFqI5cTg_2WABR6Mo15RFRgeCsQoOYxL7eO54V60SNSH_QS3mT0f",
ttl: {30, :days}
