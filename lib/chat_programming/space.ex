defmodule ChatProgramming.Space do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatProgramming.Space, as: Ele
  alias ChatProgramming.{Repo, Card, Expert}

  schema "space" do
    field :name, :string
    field :description, :string
    timestamps()

    has_many :card, Card
    has_many :expert, Expert
  end

  def all() do
    Ele
    |> Repo.all()
    |> Enum.map(&preload(&1))
  end

  def preload(ele) do
    Repo.preload(ele, [:card, :expert])
  end

  def get_by_id(id) do
    Ele
    |> Repo.get_by(id: id)
    |> preload()
  end

  def get_by_name(name) do
    Ele
    |> Repo.get_by(name: name)
    |> preload()
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
    |> cast(attrs, [:name, :description])
  end
end
