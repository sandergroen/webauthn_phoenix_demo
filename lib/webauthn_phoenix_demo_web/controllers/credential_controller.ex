defmodule WebauthnPhoenixDemoWeb.CredentialController do
  use WebauthnPhoenixDemoWeb, :controller

  def index(conn, _params) do
    case authenticate(conn) do
      %Plug.Conn{halted: true} = conn ->
        conn

      conn ->
        credentials = conn.assigns.current_user.credentials
        render(conn, "index.html", credentials: credentials)
    end
  end

  def create(conn, _) do
    case authenticate(conn) do
      %Plug.Conn{halted: true} = conn ->
        conn

      conn ->
        current_user = conn.assigns.current_user

        credential_options =
          WebAuthnEx.credential_creation_options("web-server")
          |> Map.put(:user, %{
            id: current_user.name |> Base.encode64(),
            name: current_user.name,
            displayName: current_user.name
          })

        conn = conn |> put_session(:challenge, credential_options.challenge)

        credential_options =
          credential_options
          |> Map.put(:challenge, credential_options.challenge |> Base.encode64())

        render(conn, data: Jason.encode!(credential_options))
    end
  end

  def callback(conn, %{"response" => response, "credential_name" => credential_name}) do
    case authenticate(conn) do
      %Plug.Conn{halted: true} = conn ->
        conn

      conn ->
        current_user = conn.assigns.current_user
        {:ok, client_json} = response["clientDataJSON"] |> Base.decode64()
        {:ok, attestation_object} = response["attestationObject"] |> Base.decode64()

        challenge = get_session(conn, :challenge)

        result =
          WebAuthnEx.AuthAttestationResponse.new(
            challenge,
            WebauthnPhoenixDemoWeb.Endpoint.url(),
            attestation_object,
            client_json
          )

        conn =
          case result do
            {:ok, att_resp} ->
              {{:ECPoint, public_key}, {:namedCurve, :prime256v1}} =
                att_resp.credential.public_key

              credential = %{
                user_id: current_user.id,
                credential_name: credential_name,
                external_id: Base.encode64(att_resp.credential.id),
                public_key: Base.encode64(public_key)
              }

              WebauthnPhoenixDemo.Accounts.create_credential(credential)

              conn
              |> assign(:current_user, current_user)
              |> put_session(:user_id, current_user.id)
              |> configure_session(renew: true)
              |> put_status(:ok)

            {:error, reason} ->
              conn
              |> put_status(:forbidden)
          end

        render(conn, data: Jason.encode!(%{}))
    end
  end

  def delete(conn, %{"id" => credential_id}) do
    case authenticate(conn) do
      %Plug.Conn{halted: true} = conn ->
        conn

      conn ->
        credential = WebauthnPhoenixDemo.Accounts.get_credential!(credential_id)

        case WebauthnPhoenixDemo.Accounts.delete_credential(credential) do
          {:ok, _} ->
            conn
            |> put_flash(:info, "Credential deleted!")
            |> redirect(to: Routes.credential_path(conn, :index))

          {:error, _} ->
            conn
            |> put_flash(:error, "Could not remove this credential!")
            |> redirect(to: Routes.credential_path(conn, :index))
        end
    end
  end

  defp authenticate(conn) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page!")
      |> redirect(to: Routes.session_path(conn, :index))
      |> halt()
    end
  end
end
