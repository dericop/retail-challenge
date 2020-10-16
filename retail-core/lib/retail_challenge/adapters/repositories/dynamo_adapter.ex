defmodule RetailChallenge.Adapters.Dynamo.DynamoAdapter do
  alias RetailChallenge.Config.ConfigHolder

  def health() do
    case ExAws.Dynamo.describe_table('products') do
      %{
        data: %{
          "TableName" => table_name
        }
      } -> {:ok, table_name}
      error -> {:error, error}
    end
  end

  def get_dynamo_value(table, key) do
    ExAws.Dynamo.get_item(table, key)
    |> execute()
  end

  def get_dynamo_value_index(table, attr, key, index) do
    ExAws.Dynamo.query(
      table,
      limit: 1,
      index_name: index,
      expression_attribute_values: [
        key: key
      ],
      key_condition_expression: attr <> " = :key"
    )
    |> execute()
  end

  def put_dynamo_value(table, item = %{}) do
    ExAws.Dynamo.put_item(table, item)
    |> execute()
  end

  def execute(op) do
    ExAws.request(op, region: ConfigHolder.conf.region)
  end
end
