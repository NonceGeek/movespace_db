defmodule ChatProgramming.PromptHandler do
  @moduledoc """
    TODO: impl the real functions.
  """

  def recog_vars(prompt) do
    ["topic"]
  end

  def impl_vars(prompt, vars) do
    Enum.reduce(vars, prompt, fn {key, value}, acc ->
      IO.puts inspect key
      IO.puts inspect value
      String.replace(acc, "{#{key}}", value)
    end)
    # Enum.reduce([1, 2, 3], 0, fn x, acc -> x + acc end)
  end
end
