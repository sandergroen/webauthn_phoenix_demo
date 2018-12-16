defmodule WebauthnPhoenixDemo.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credentials" do
    field :credential_name, :string
    field :external_id, :string
    field :public_key, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:user_id, :credential_name, :external_id, :public_key])
    |> validate_required([:credential_name, :external_id, :public_key])
  end
end
