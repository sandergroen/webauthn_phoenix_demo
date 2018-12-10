defmodule WebauthnPhoenixDemo.Repo do
  use Ecto.Repo,
    otp_app: :webauthn_phoenix_demo,
    adapter: Ecto.Adapters.Postgres
end
