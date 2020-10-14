defmodule RetailChallenge.Adapters.Repositories.User do
  use Ecto.Schema

  @primary_key {:username, :string, []}
  schema "users" do
    field(:token)
    field(:age, :integer)
  end
end
