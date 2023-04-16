defmodule ChatProgramming.Repo.Migrations.CreateExpert do
  use Ecto.Migration

  def change do
    create table(:expert) do
      add :name, :string
      add :description, :text
      add :url, :string
      add :avatar, :string
      add :space_id, :integer
      timestamps()
    end
  end
end
