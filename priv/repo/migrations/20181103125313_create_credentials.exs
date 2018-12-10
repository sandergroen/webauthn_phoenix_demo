defmodule WebauthnPhoenixDemo.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :credential_name, :string
      add :external_id, :string
      add :public_key, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:credentials, [:user_id])
    create index(:credentials, [:external_id], unique: true)
  end
end
