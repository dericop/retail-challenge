defmodule RetailChallenge.Adapters.Repositories.UserGateway do
  alias RetailChallenge.Adapters.Repositories.{User, Repo, RepoCache}

  def get_by_username(username) do
    RepoCache.get(username, fn -> get_by_username_from_repo(username) end)
  end

  def get_by_token(token) do
    RepoCache.get(token, fn -> get_by_token_from_repo(token) end)
  end

  defp get_by_username_from_repo(username) do
    Repo.get(User, username)
    |> extract()
  end

  defp get_by_token_from_repo(token) do
    Repo.get_by(User, token: token)
    |> extract()
  end

  defp extract(result) do
    case result do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
      other -> {:error, other}
    end
  end

end
