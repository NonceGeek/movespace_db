defmodule ChatProgramming.Repo.Migrations.CreatePermission do
  use Ecto.Migration

  def change do
    create table :permission do
      add :level, :integer
      add :remaining_times, :integer
      add :user_id, :integer

      timestamps()
    end
  end
end
