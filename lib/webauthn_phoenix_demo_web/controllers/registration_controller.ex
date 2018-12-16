defmodule WebauthnPhoenixDemoWeb.RegistrationController do
  use WebauthnPhoenixDemoWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end

  def create(conn, %{"name" => username}) do
    credential_options =
      WebAuthnEx.credential_creation_options("web-server", "localhost")
      |> Map.put(:user, %{id: username |> Base.encode64(), name: username, displayName: username})

    conn = conn |> put_session(:challenge, credential_options.challenge)

    credential_options =
      credential_options |> Map.put(:challenge, credential_options.challenge |> Base.encode64())

    render(conn, data: Jason.encode!(credential_options))
  end

  def callback(conn, %{"response" => response, "credential_name" => credential_name, "name" => name}) do
    {:ok, client_json} = response["clientDataJSON"] |> Base.decode64()
    {:ok, attestation_object} = response["attestationObject"] |> Base.decode64()

    challenge = get_session(conn, :challenge)

    result = WebAuthnEx.AuthAttestationResponse.new(
      challenge,
      WebauthnPhoenixDemoWeb.Endpoint.url(),
      attestation_object,
      client_json
    )

    conn = case result do
        {:ok, att_resp} ->
          {{:ECPoint, public_key}, {:namedCurve, :prime256v1}} = att_resp.credential.public_key
          credential = %{
            "credential_name" => credential_name,
            "external_id" => Base.encode64(att_resp.credential.id),
            "public_key" => Base.encode64(public_key)
          }
          user = WebauthnPhoenixDemo.Accounts.register_user(name, credential)

          conn
            |> assign(:current_user, user)
            |> put_session(:user_id, user.id)
            |> configure_session(renew: true)
        {:error, reason} ->
          conn
            |> put_status(:forbidden)
      end

    render(conn, data: Jason.encode!(%{}))
  end
end
