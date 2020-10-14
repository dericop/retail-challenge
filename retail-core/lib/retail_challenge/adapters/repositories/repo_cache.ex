defmodule RetailChallenge.Adapters.Repositories.RepoCache do
  use GenServer
  require Logger
  @table_name :apps_cache

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get(key, fallback) do
    case get(key) do
      :not_found -> exec_fallback(key, fallback)
      value -> value
    end
  end

  def put(_key, nil), do: :ok
  def put(key, val) do
    GenServer.cast(__MODULE__, {:put, key, val})
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  def get(key) do
    case :ets.lookup(@table_name, key) do
      [{^key, value} | _rest] -> value
      [] -> :not_found
    end
  end

  defp exec_fallback(key, fallback_function) do
    Logger.debug "cache miss for #{inspect(key)}"
    case fallback_function.() do
      {:ok, value} = res -> put(key, res)
                            res
      error -> error
    end
  end

  def init(_args) do
    create_table()
    {:ok, %{started_at: :os.system_time(:millisecond)}}
  end

  def handle_cast({:put, key, val}, state) do
    :ets.insert(@table_name, {key, val})
    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    :ets.delete(@table_name, key)
    {:noreply, state}
  end

  defp create_table() do
    :ets.new(@table_name, [:named_table, read_concurrency: true])
  end
end
