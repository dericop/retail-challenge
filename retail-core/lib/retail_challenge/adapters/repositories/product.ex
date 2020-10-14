defmodule RetailChallenge.Adapters.Repositories.Product do
  alias RetailChallenge.Adapters.Repositories.Sale
  use Ecto.Schema

  @primary_key {:sku, :string, []}
  schema "products" do
    field(:description)
    field(:stock, :integer)
    field(:price, :decimal)
    has_many :sales, Sale, foreign_key: :product_id
  end
end
