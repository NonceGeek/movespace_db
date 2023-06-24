defmodule ChatProgramming.Repo.Migrations.UpdatePermission do
  use Ecto.Migration

  def change do
    alter table :permission do
      add :remaining_tokens, :integer
    end
  end
end
