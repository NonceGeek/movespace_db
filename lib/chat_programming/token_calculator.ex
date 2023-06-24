defmodule ChatProgramming.TokenCaculator do
  alias ChatProgramming.Accounts.User
  alias ChatProgramming.Permission

  def calculate(payload) do
    # TODO cal more accurately
    byte_size(payload)
  end

  def using_users_token(%User{permission: permission}, payload) do
    token_size = calculate(payload)

  end
end
