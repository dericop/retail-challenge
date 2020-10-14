defmodule RetailChallenge.Adapters.Repositories.Repo do
  alias RetailChallenge.Adapters.Secrets.SecretManagerAdapter
  alias Ecto.Adapters.SQL
  alias DBConnection.ConnectionError
  alias RetailChallenge.Utils.DataTypeUtils
  use Ecto.Repo,
      otp_app: :retail_challenge,
      adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    %{
      DB_HOST: hostname,
      DB_PORT: port,
      DB_USERNAME: username,
      DB_PASSWORD: password,
      DB_NAME: database
    } = SecretManagerAdapter.get_secret()

    config = config
             |> Keyword.put(:hostname, hostname)
             |> Keyword.put(:port, port)
             |> Keyword.put(:username, username)
             |> Keyword.put(:password, password)
             |> Keyword.put(:database, database)

    {:ok, config}
  end

  def health() do
    try do
      case SQL.query(__MODULE__, "select 1", []) do
        {:ok, _res} -> {:ok, :up}
        _error -> :error
      end
    rescue
      ConnectionError -> :error
    end
  end


end
