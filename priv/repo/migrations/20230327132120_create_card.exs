defmodule ChatProgramming.Repo.Migrations.CreateCard do
  use Ecto.Migration

  def change do
    create table(:card) do
      add :title, :string
      add :url, :string
      add :context, :text
      add :space_id, :integer
      timestamps()
    end

    create table(:space) do
      add :name, :string
      add :description, :text
      timestamps()
    end

    create table(:chat_history) do
      add :question, :text
      add :result, :text
      add :if_awesome, :boolean

      add :space_id, :integer
      add :user_id, :integer

      timestamps()
    end
  end
end
