defmodule ChatProgramming.Proposal do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatProgramming.Proposal, as: Ele
  alias ChatProgramming.{Repo}

  schema "proposal" do
    field :title, :string
    field :content, :string
    field :contributor, :string
    field :dataset_id, :string
    field :if_approved, :boolean, default: false
    timestamps()
  end

  def get_all() do
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
    |> cast(attrs, [:title, :content, :dataset_id, :if_approved, :contributor])
  end
end
