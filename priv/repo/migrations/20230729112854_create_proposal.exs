defmodule ChatProgramming.Repo.Migrations.CreateProposal do
  use Ecto.Migration

  def change do
    create table :proposal do
      add :title, :string
      add :contributor, :string
      add :content, :text
      add :dataset_id, :string
      add :if_approved, :boolean

      timestamps()
    end
  end
end
