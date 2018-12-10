defmodule WebauthnPhoenixDemoWeb.RegistrationView do
  use WebauthnPhoenixDemoWeb, :view

  def render("create.json", %{data: data}) do
    data
  end

  def render("callback.json", %{data: result}) do
    result
  end
end
