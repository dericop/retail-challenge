use Mix.Config

config :retail_challenge,
       http_port: 3000,
       enable_server: false,
       secret_name: "",
       region: "us-east-1",
       in_test: true,
       version: "1.3.3",
       migrate: true

config :ex_aws,
       region: "us-east-1",
       access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
       secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]
