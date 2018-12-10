# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WebauthnPhoenixDemo.Repo.insert!(%WebauthnPhoenixDemo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias WebauthnPhoenixDemo.Repo
alias WebauthnPhoenixDemo.Accounts.{User, Credential}

Repo.insert!(%User{
  name: "Sander",
  credentials: [
    %Credential{credential_name: "credential1", external_id: "123", public_key: "abc"}
  ]
})
