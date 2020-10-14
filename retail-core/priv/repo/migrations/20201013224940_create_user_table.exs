defmodule RetailChallenge.Adapters.Repositories.Repo.Migrations.CreateUserTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :username, :string, size: 36, primary_key: true
      add :token, :string, size: 256
      add :age, :integer
    end
    create index(:users, [:token], comment: "Index For Token", unique: true)
  end

end
