defmodule ChatProgramming.ChatHistory do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatProgramming.ChatHistory, as: Ele
  alias ChatProgramming.{Repo, Space}
  alias ChatProgramming.Accounts.User

  schema "chat_history" do
    field :question, :string
    field :result, :string
    field :if_awesome, :boolean, default: false
    belongs_to :user, User
    belongs_to :space, Space
    timestamps()
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
    |> cast(attrs, [:question, :result, :if_awesome, :space_id, :user_id])
  end
end
