defmodule WebauthnPhoenixDemo.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias WebauthnPhoenixDemo.Accounts.Credential

  schema "users" do
    field :name, :string
    has_many :credentials, WebauthnPhoenixDemo.Accounts.Credential
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast_assoc(:credentials, with: &Credential.changeset/2, required: true)
  end
end
