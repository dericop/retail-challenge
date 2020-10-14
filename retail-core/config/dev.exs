import Config

config :retail_challenge,
       http_port: 3000,
       enable_server: true,
       secret_name: "retail-challenge-secret",
       region: "us-east-1",
       version: "1.2.3",
       migrate: true

config :ex_aws,
       region: "us-east-1",
       access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, {:awscli, "default", 30}, :instance_role],
       secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, {:awscli, "default", 30}, :instance_role]

config :logger,
       level: :debug

config :retail_challenge,
       RetailChallenge.Adapters.Repositories.Repo,
       database: "postgresql",
       username: "loaded_from_secret",
       password: "loaded_from_secret",
       hostname: "loaded_from_secret",
       pool_size: 10

config :retail_challenge, ecto_repos: [RetailChallenge.Adapters.Repositories.Repo]
