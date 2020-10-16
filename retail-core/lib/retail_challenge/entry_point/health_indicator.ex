defmodule RetailChallenge.EntryPoint.Rest.HealthIndicator do
  require Logger
  alias RetailChallenge.Adapters.Repositories.Repo
  alias RetailChallenge.Config.ConfigHolder

  def health() do
    version = ConfigHolder.conf().version
    Poison.encode!(%{status: "UP", version: version})
    #    case Repo.health() do
    #      {:ok, _} -> Poison.encode!(%{status: "UP", version: version})
    #      error -> Logger.error "Health check error: #{inspect(error)}"
    #               %{status: 503, body: Poison.encode!(%{status: "DOWN", version: version})}
    #    end
  end

end
