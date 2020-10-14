defmodule RetailChallenge.Adapters.Repositories.SaleGateway do
  alias RetailChallenge.Adapters.Repositories.{Sale, Repo}

  def get_by_id(id) do
    Repo.get(Sale, id)
    |> extract()
  end

  def save(sale = %Sale{}) do
    Repo.insert(sale)
    |> extract()
  end

  defp extract(result) do
    case result do
      %Sale{} = sale -> {:ok, sale}
      {:ok, %Sale{}} = res -> res
      nil -> {:error, :not_found}
      other -> {:error, other}
    end
  end

end
