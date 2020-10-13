defmodule RetailChallenge.Config.AppConfig do
  defstruct [
    :http_port,
    :enable_server,
    :secret_name,
    :region,
    :version
  ]

  def load_config do
    %__MODULE__{
      http_port: load(:http_port),
      enable_server: load(:enable_server),
      secret_name: load(:secret_name),
      region: load(:region),
      version: load(:version)
    }
  end

  defp load(property_name), do: Application.fetch_env!(:retail_challenge, property_name)
end
