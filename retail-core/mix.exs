defmodule RetailChallenge.MixProject do
  use Mix.Project

  def project do
    [
      app: :retail_challenge,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RetailChallenge.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.4"},
      {:postgrex, "~> 0.15.0"},
      {:uuid, "~> 1.1"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_secretsmanager, "~> 2.0"},
      {:ex_aws_dynamo, "~> 2.0"},
      {:configparser_ex, "~> 4.0"},
      {:plug_cowboy, "~> 2.2"},
      {:poison, "~> 4.0"},
      {:jason, "~> 1.2"},
      {:hackney, "~> 1.9"},
      {:ecto_boot_migration, "~> 0.2.0"},
      {:distillery, "~> 2.1"},
    ]
  end
end
