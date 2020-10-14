defmodule RetailChallenge.Adapters.Repositories.ProductGateway do
  alias RetailChallenge.Adapters.Repositories.{Product, Repo}
  alias Ecto.Adapters.SQL

  def get_by_sku(sku) do
    Repo.get(Product, sku)
    |> extract()
  end

  def update_stock(%Product{} = product, sold) do
    query = "UPDATE products SET stock = stock - $1 WHERE sku = $2"
    case SQL.query(Repo, query, [sold, product.sku]) do
      {:ok, %{num_rows: 0}} -> {:error, :not_found}
      {:ok, %{num_rows: 1}} -> {:ok, product}
      {
        :error,
        %{
          postgres: %{
            constraint: "stock_must_be_at_least_zero"
          }
        }
      } -> {:error, :stock_not_available}
      error -> error
    end
  end

  defp extract(result) do
    case result do
      %Product{} = product -> {:ok, product}
      nil -> {:error, :not_found}
      other -> {:error, other}
    end
  end

end
