defmodule RetailChallenge.Adapters.Repositories.Sale do
  alias RetailChallenge.Adapters.Repositories.{User, Product}
  use Ecto.Schema

  schema "sales" do
    field(:amount, :integer)
    field(:total_price, :decimal)

    belongs_to :user, User, references: :username, type: :string, foreign_key: :buyer_id
    belongs_to :product, Product, references: :sku, type: :string
  end

  def new(amount, product = %Product{}, user = %User{}) do
    %__MODULE__{
      amount: amount,
      total_price: Decimal.mult(product.price, amount),
      product: product,
      user: user
    }
  end
end
