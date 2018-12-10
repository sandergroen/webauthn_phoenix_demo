defmodule WebauthnPhoenixDemoWeb.Auth do
  import Plug.Conn

  alias WebauthnPhoenixDemo.Accounts
  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end
