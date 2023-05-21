defmodule ChatProgramming.Repo.Migrations.OpenaiFinetuneHistory do
  use Ecto.Migration

  def change do
    create table :openai_finetune_history do
      add :unique_id, :string
      add :finished, :boolean
      add :openai_file_id, :integer
      add :openai_model_id, :integer
      timestamps()
    end
  end

end
