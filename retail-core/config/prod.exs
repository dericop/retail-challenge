import Config

config :retail_challenge,
       http_port: 3000,
       enable_server: true,
       secret_name: System.get_env("secret_name"),
       region: System.get_env("region"),
       version: System.get_env("version")

config :ex_aws,
       region: "us-east-1",
       access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
       secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

config :logger,
       level: :warn,
       compile_time_purge_matching: [
         [level_lower_than: :info]
       ]

config :retail_challenge,
       RetailChallenge.Adapters.Repositories.Repo,
       database: System.get_env("database"),
       username: System.get_env("username"),
       password: System.get_env("password"),
       hostname: System.get_env("hostname"),
       pool_size: System.get_env("pool_size")
