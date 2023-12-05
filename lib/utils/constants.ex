defmodule Constants do
  def service_smart_prompter?() do
    case System.get_env("SMART_PROMPTER") do
      "0" ->
        false
      "1" ->
        true
      _ ->
        false
    end
  end

  def smart_prompter_endpoint() do
    System.get_env("SMART_PROMPTER_ENDPOINT")
  end

  def embedbase_key() do
    System.get_env("EMBEDBASE_KEY")
  end

  def smart_prompter_endpoint() do
    System.get_env("SMART_PROMPTER_ENDPOINT")
  end

  def smart_prompter_acct() do
    System.get_env("SMART_PROMPTER_ACCT")
  end

  def smart_prompter_pwd() do
    System.get_env("SMART_PROMPTER_PWD")
  end

  def greenfield_sp_endpoint() do
    "https://greenfield-sp.defibit.io"
  end

  def greenfield_endpoint() do
    "https://greenfield-chain-us.bnbchain.org"
  end

  def movespace_endpoint() do
    "https://faas.movespace.xyz"
  end

  def movespace_api_key() do
    System.get_env("MOVESPACE_API_KEY")
  end
end
