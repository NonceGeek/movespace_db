defmodule ChatProgramming.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :name, :string
      add :user_id, :integer
      add :path, :string

      timestamps()
    end

    create index(:uploads, [:user_id])
  end
end
