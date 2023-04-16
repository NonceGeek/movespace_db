defmodule ChatProgramming.Card do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatProgramming.Card, as: Ele
  alias ChatProgramming.{Repo, Space}

  schema "card" do
    field :title, :string
    field :url, :string
    field :context, :string
    belongs_to :space, Space
    timestamps()
  end

  def preload(ele) do
    Repo.preload(ele, :space)
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
    |> cast(attrs, [:title, :context, :url, :space_id])
  end
end
