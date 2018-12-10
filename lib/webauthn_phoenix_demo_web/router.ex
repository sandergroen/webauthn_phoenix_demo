defmodule WebauthnPhoenixDemoWeb.Router do
  use WebauthnPhoenixDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WebauthnPhoenixDemoWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug WebauthnPhoenixDemoWeb.Auth
  end

  scope "/", WebauthnPhoenixDemoWeb do
    pipe_through :browser

    resources "/", CredentialController, only: [:index, :delete]
    resources "/sessions", SessionController, only: [:index, :delete]
    get "/registration", RegistrationController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", WebauthnPhoenixDemoWeb do
    pipe_through :api
    post "/session", SessionController, :create
    post "/session/callback", SessionController, :callback
    post "/registration", RegistrationController, :create
    post "/registration/callback", RegistrationController, :callback

    post "/credential", CredentialController, :create
    post "/credential/callback", CredentialController, :callback
  end
end
