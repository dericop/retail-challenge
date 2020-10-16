defmodule RetailChallenge.Adapters.Repositories.SaleDGateway do
  alias RetailChallenge.Adapters.Dynamo.DynamoAdapter
  alias RetailChallenge.Adapters.Repositories.{Sale}
  @table "sales"

  def save(sale = %Sale{}) do
    model = model_to_dynamo(sale)
    DynamoAdapter.put_dynamo_value(@table, model)
    |> case do
         {:ok, %{}} -> {:ok, %{id: model.id}}
         other -> other
       end
  end

  defp model_to_dynamo(
         %Sale{
           amount: amount,
           product: %{
             sku: product_id
           },
           user: %{
             username: username
           },
           total_price: total_price
         }
       ) do
    total_price = Decimal.to_float(total_price)
    %{amount: amount, product_id: product_id, total_price: total_price, username: username, id: UUID.uuid4()}
  end

end
