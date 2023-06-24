defmodule ChatProgramming.Permission do
    use Ecto.Schema
    import Ecto.Changeset
    alias ChatProgramming.Permission, as: Ele
    alias ChatProgramming.Repo
    alias ChatProgramming.Accounts.User

    schema "permission" do
      field :level, :integer, default: 0
      field :remaining_times, :integer, default: 100
      field :remaining_tokens, :integer, default: 5000
      belongs_to :user, User
      timestamps()
    end

    def reset_remaining_times() do
      all()
      |> Enum.each(fn permission ->
        do_reset_remaining_times(permission)
      end)
    end

    def do_reset_remaining_times(%{level: level} = permission)
      when level == 0 do
        update(permission, %{level: 0})
    end
    def do_reset_remaining_times(permission), do: permission

    def all(), do: Repo.all(Ele)

    def preload(ele) do
      Repo.preload(ele, :user)
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
      |> cast(attrs, [:level, :remaining_times, :user_id, :remaining_tokens])
    end
  end
