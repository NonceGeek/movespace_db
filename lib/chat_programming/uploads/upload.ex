defmodule ChatProgramming.Uploads.Upload do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field :name, :string
    field :path, :string

    belongs_to :user, ChatProgramming.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:name, :user_id, :path])
    |> validate_required([:name, :user_id, :path])
  end
end
