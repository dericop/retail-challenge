defmodule RetailChallenge.Adapters.Repositories.Product do
  use Ecto.Schema

  @primary_key {:sku, :string, []}
  schema "products" do
    field(:description)
    field(:stock, :integer)
    field(:price, :decimal)
  end
end
