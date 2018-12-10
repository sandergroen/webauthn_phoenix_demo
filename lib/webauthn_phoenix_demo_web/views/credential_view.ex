defmodule WebauthnPhoenixDemoWeb.CredentialView do
  use WebauthnPhoenixDemoWeb, :view

  def render("create.json", %{data: data}) do
    data
  end

  def render("callback.json", %{data: result}) do
    result
  end

  def can_delete_credentials?(user) do
    Enum.count(user.credentials) > 1
  end
end
