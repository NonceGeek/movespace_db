defmodule ChatProgramming.VectorDatasetItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatProgramming.Repo
  alias ChatProgramming.VectorDatasetItem, as: Ele

  schema "vector_dataset_item" do
    field :unique_id, :string
    field :context, :string
    field :arweave_tx_id, :string
    field :origin_dataset_name, :string
    field :tags, :map
    timestamps()
  end

  def all() do
    Repo.all(Ele)
  end

  def get_by_id(id) do
    Repo.get_by(Ele, id: id)
  end

  def create(attrs \\ %{}) do
    %Ele{}
    |> Ele.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Ele{} = ele, attrs) do
    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(%Ele{} = ele) do
    Ele.changeset(ele, %{})
  end

  @doc false
  def changeset(%Ele{} = ele, attrs) do
    ele
    |> cast(attrs, [:unique_id, :context, :arweave_tx_id, :origin_dataset_name, :tags])
  end
end
