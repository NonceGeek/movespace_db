defmodule ChatProgramming.Repo.Migrations.CreateEmbedbase do
  use Ecto.Migration

  def change do
    create table :embedbase do
      add :dataset_id, :string
      timestamps()
    end
  end
end
