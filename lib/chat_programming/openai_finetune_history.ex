defmodule ChatProgramming.OpenAIFinetuneHistory do
    use Ecto.Schema
    import Ecto.Changeset
    import Ecto.Query, only: [from: 2]

    alias ChatProgramming.{OpenAIModel, OpenAIFile}
    alias ChatProgramming.Repo

    schema "openai_finetune_history" do
      field :unique_id, :string
      field :finished, :boolean, default: false
      belongs_to :openai_model, OpenAIModel
      belongs_to :openai_file, OpenAIFile

      timestamps()
    end

    def get_latest_one() do
      Repo.one(from x in __MODULE__, order_by: [desc: x.id], limit: 1)
    end



    def all(), do: Repo.all(__MODULE__)

    def preload(ele) do
      Repo.preload(ele, [:openai_files])
    end

    def get!(id) do
      Repo.get_by(__MODULE__, id: id)
    end

    def get_by_unique_id(id) do
      Repo.get_by(__MODULE__, unique_id: id)
    end

    def create(attrs \\ %{}) do
      %__MODULE__{}
      |> changeset(attrs)
      |> Repo.insert()
    end

    def update(%__MODULE__{} = ele, attrs) do
      ele
      |> changeset(attrs)
      |> Repo.update()
    end

    def changeset(%__MODULE__{} = ele) do
      changeset(ele, %{})
    end

    @doc false
    def changeset(%__MODULE__{} = ele, attrs) do
      ele
      |> cast(attrs, [:unique_id, :finished, :openai_model_id, :openai_file_id])
    end

  end
