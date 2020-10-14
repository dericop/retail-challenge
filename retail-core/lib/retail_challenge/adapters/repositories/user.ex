defmodule RetailChallenge.Adapters.Repositories.User do
  alias RetailChallenge.Adapters.Repositories.Sale
  use Ecto.Schema

  @primary_key {:username, :string, []}
  schema "users" do
    field(:token)
    field(:age, :integer)
    has_many :sales, Sale, foreign_key: :buyer_id
  end
end
