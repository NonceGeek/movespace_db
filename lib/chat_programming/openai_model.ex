defmodule ChatProgramming.OpenAIModel do
    use Ecto.Schema
    import Ecto.Changeset

    alias ChatProgramming.{OpenAIFile, OpenAIFinetuneHistory}
    alias ChatProgramming.Repo

    schema "openai_model" do
      field :model_unique_id, :string
      has_many :openai_files, OpenAIFile
      has_many :openai_finetune_histories, OpenAIFinetuneHistory

      timestamps()
    end


    def all(), do: Repo.all(__MODULE__)

    def preload(ele) do
      Repo.preload(ele, [:openai_files])
    end

    def get_by_id(id) do
      Repo.get_by(__MODULE__, id: id)
    end


    def get_by_unique_id(id) do
      Repo.get_by(__MODULE__, model_unique_id: id)
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
      |> cast(attrs, [:model_unique_id])
    end

  end
