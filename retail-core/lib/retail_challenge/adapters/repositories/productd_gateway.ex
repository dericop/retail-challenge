defmodule RetailChallenge.Adapters.Repositories.ProductDGateway do
  alias RetailChallenge.Adapters.Dynamo.DynamoAdapter
  alias RetailChallenge.Adapters.Repositories.{Product, RepoCache}
  @table "products"

  def get_by_sku_cached(sku) do
    RepoCache.get(sku, fn -> get_by_sku(sku) end)
  end

  def get_by_sku(sku) do
    case DynamoAdapter.get_dynamo_value(@table, %{sku: sku}) do
      {:ok, %{"Item" => res}} -> dynamo_to_model(res)
      {:ok, _res} -> {:error, :not_found}
      other -> {:error, other}
    end
  end

  def update_stock(%Product{sku: sku}, sold) do
    ExAws.Dynamo.update_item(
      @table,
      %{sku: sku},
      update_expression: "set Cantidad = Cantidad - :quantity",
      condition_expression: "Cantidad >= :quantity",
      expression_attribute_values: [
        quantity: sold
      ]
    )
    |> DynamoAdapter.execute()
    |> case do
         {:error, {"ConditionalCheckFailedException", "The conditional request failed"}} ->
           {:error, :stock_not_available}
         other -> other
       end
  end

  defp dynamo_to_model(
         %{
           "Cantidad" => %{
             "N" => stock
           },
           "descripcion" => %{
             "S" => description
           },
           "Precio" => %{
             "N" => price
           },
           "sku" => %{
             "S" => sku
           }
         }
       ) do
    {stock, _} = Integer.parse(stock)
    price = Decimal.new(price)
    {:ok, %Product{sku: sku, description: description, price: price, stock: stock}}
  end
  defp dynamo_to_model(res), do: {:error, res}

end
