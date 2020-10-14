defmodule RetailChallenge.Adapters.Repositories.Repo.Migrations.CreateProductTable do
  use Ecto.Migration

  def change do
    create table("products", primary_key: false) do
      add :sku, :string, size: 36, primary_key: true
      add :description, :string, size: 256
      add :stock, :integer
      add :price, :decimal
    end
    create constraint("products", "stock_must_be_at_least_zero", check: "stock >= 0", comment: "Check stock")
  end

end
