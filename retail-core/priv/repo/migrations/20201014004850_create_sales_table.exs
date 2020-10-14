defmodule RetailChallenge.Adapters.Repositories.Repo.Migrations.CreateSalesTable do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :amount, :integer
      add :total_price, :decimal
      add :product_id, references(:products, column: :sku, type: :string, on_delete: :delete_all), null: false, size: 36
      add :buyer_id, references(:users, column: :username, type: :string, on_delete: :delete_all), null: false, size: 36
    end
  end
end
