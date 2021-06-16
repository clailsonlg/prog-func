defmodule Pfu.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute("CREATE TYPE tipo_user AS ENUM ('Professor','AlunoMestrado','AlunoGraduacao')")
    create table(:users) do
      add :name, :string
      add :username, :string, null: false
      add :password_hash, :string

      timestamps()
    end
    create unique_index(:users, [:username])

    execute("alter table users add tipo tipo_user")

  end
end
