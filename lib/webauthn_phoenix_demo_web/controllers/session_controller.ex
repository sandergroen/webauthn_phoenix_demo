defmodule WebauthnPhoenixDemoWeb.SessionController do
  use WebauthnPhoenixDemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, %{"name" => username}) do
    user = WebauthnPhoenixDemo.Accounts.get_user_by_name(username)
    credential_options = WebAuthnEx.credential_request_options()

    conn =
      conn
      |> put_session(:challenge, credential_options.challenge)
      |> put_session(:username, username)

    credential_options =
      credential_options
      |> Map.put(
        :allowCredentials,
        Enum.map(user.credentials, fn credential ->
          %{id: credential.external_id, type: "public-key"}
        end)
      )
      |> Map.put(:challenge, Base.encode64(credential_options.challenge))

    render(conn, data: Jason.encode!(credential_options))
  end

  def callback(conn, %{"id" => id, "response" => response}) do
    {:ok, authenticator_data} = response["authenticatorData"] |> Base.decode64()
    {:ok, client_data_json} = response["clientDataJSON"] |> Base.decode64()
    {:ok, signature} = response["signature"] |> Base.decode64()

    username = get_session(conn, :username)
    challenge = get_session(conn, :challenge)
    user = WebauthnPhoenixDemo.Accounts.get_user_by_name(username)

    {:ok, auth_response} =
      WebAuthnEx.AuthAssertionResponse.new(
        id |> Base.decode64!(),
        authenticator_data,
        signature
      )

    allowed_credentials =
      Enum.map(user.credentials, fn cred ->
        %{id: Base.decode64!(cred.external_id), public_key: Base.decode64!(cred.public_key)}
      end)

    result =
      WebAuthnEx.AuthAssertionResponse.valid?(
        challenge,
        WebauthnPhoenixDemoWeb.Endpoint.url(),
        allowed_credentials,
        nil,
        client_data_json,
        auth_response
      )

    conn =
      case result do
        false ->
          conn |> put_status(403)

        true ->
          conn
          |> assign(:current_user, user)
          |> put_session(:user_id, user.id)
          |> configure_session(renew: true)
          |> put_status(:ok)
      end

    render(conn, data: Jason.encode!(%{data: result}))
  end

  def delete(conn, _) do
    conn
    |> WebauthnPhoenixDemoWeb.Auth.logout()
    |> redirect(to: Routes.session_path(conn, :index))
  end
end
