defmodule ChatProgramming.Repo.Migrations.CreateVectorDatasetItem do
  use Ecto.Migration

  def change do
    create table :vector_dataset_item do
      add :unique_id, :string
      add :context, :text
      add :arweave_tx_id, :string
      add :origin_dataset_name, :string
      add :tags, :map

      timestamps()
    end
  end 
end
