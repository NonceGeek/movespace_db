defmodule ChatProgramming.Repo do
  use Ecto.Repo,
    otp_app: :chat_programming,
    adapter: Ecto.Adapters.Postgres
end
