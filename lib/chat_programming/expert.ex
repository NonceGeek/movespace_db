defmodule ChatProgramming.Expert do
    use Ecto.Schema
    import Ecto.Changeset
    alias ChatProgramming.Expert, as: Ele
    alias ChatProgramming.{Repo, Space}

    schema "expert" do
      field :name, :string
      field :description, :string
      field :url, :string
      field :avatar, :string
      belongs_to :space, Space
      timestamps()
    end

    def all(), do: Ele |> Repo.all() |> Enum.map(&(preload(&1)))

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
      |> cast(attrs, [:name, :description, :avatar, :url, :space_id])
    end
  end
