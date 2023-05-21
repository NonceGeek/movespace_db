defmodule ChatProgramming.Repo.Migrations.OpenAIFile do
  use Ecto.Migration

  def change do
    create table :openai_file do
      add :file_unique_id, :string
      add :upload_id, :integer
      timestamps()
    end

    create table :openai_model do
      add :model_unique_id, :string
      timestamps()
    end

  end

end
