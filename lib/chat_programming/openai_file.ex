defmodule ChatProgramming.OpenAIFile do
    use Ecto.Schema
    import Ecto.Changeset
    import Ecto.Query, only: [from: 2]

    alias ChatProgramming.Uploads.Upload
    alias ChatProgramming.{OpenAIModel, OpenAIFinetuneHistory}
    alias ChatProgramming.Repo


    schema "openai_file" do
      field :file_unique_id, :string
      belongs_to :upload, Upload
      has_many :openai_finetune_histories, OpenAIFinetuneHistory

      timestamps()
    end

    def get_by_unique_id(file_unique_id) do
      Repo.get_by(__MODULE__, file_unique_id: file_unique_id)
    end

    def all(), do: Repo.all(__MODULE__)

    def preload(ele) do
      Repo.preload(ele, [:upload, :model])
    end

    def get_latest_one() do
      Repo.one(from x in __MODULE__, order_by: [desc: x.id], limit: 1)
    end

    def get!(id) do
      Repo.get_by(__MODULE__, id: id)
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
      |> cast(attrs, [:file_unique_id, :upload_id])
    end

  end
