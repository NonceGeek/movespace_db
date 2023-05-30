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

end
