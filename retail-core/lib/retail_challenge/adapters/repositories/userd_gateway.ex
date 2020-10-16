defmodule RetailChallenge.Adapters.Repositories.UserDGateway do
  alias RetailChallenge.Adapters.Dynamo.DynamoAdapter
  alias RetailChallenge.Adapters.Repositories.{User, RepoCache}
  @table "users"
  @sec_idx_attr "ctoken"
  @sec_idx_name "ctoken-index"

  def get_by_username(username) do
    RepoCache.get(username, fn -> get_by_username_from_repo(username) end)
  end

  def get_by_token(token) do
    RepoCache.get(token, fn -> get_by_token_from_repo(token) end)
  end

  defp get_by_username_from_repo(username) do
    case DynamoAdapter.get_dynamo_value(@table, %{username: username}) do
      {:ok, %{"Item" => res}} -> dynamo_to_model(res)
      {:ok, _res} -> {:error, :not_found}
      other -> {:error, other}
    end
  end

  defp get_by_token_from_repo(token) do
    case DynamoAdapter.get_dynamo_value_index(@table, @sec_idx_attr, token, @sec_idx_name) do
      {:ok, %{"Count" => 0}} -> {:error, :not_found}
      {:ok, %{"Count" => 1, "Items" => [res]}} -> dynamo_to_model(res)
      other -> {:error, other}
    end
  end

  defp dynamo_to_model(
         %{
           "ctoken" => %{
             "S" => token
           },
           "edad" => %{
             "S" => age
           },
           "username" => %{
             "S" => username
           }
         }
       ) do
    {age, _} = Integer.parse(age)
    {:ok, %User{token: token, age: age, username: username}}
  end
  defp dynamo_to_model(res), do: {:error, res}

end
