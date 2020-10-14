defmodule RetailChallenge.Adapters.Repositories.Migrator do
  use GenServer
  alias RetailChallenge.Config.ConfigHolder

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    if(ConfigHolder.conf().migrate) do
      EctoBootMigration.migrate(:retail_challenge)
    else
      {:ok, "migration not executed"}
    end
  end

end
