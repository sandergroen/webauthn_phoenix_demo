use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :webauthn_phoenix_demo, WebauthnPhoenixDemoWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :webauthn_phoenix_demo, WebauthnPhoenixDemo.Repo,
  username: "postgres",
  password: "postgres",
  database: "webauthn_phoenix_demo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
