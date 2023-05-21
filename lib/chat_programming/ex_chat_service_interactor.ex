defmodule ChatProgramming.ExChatServiceInteractor do

  @doc """
    OpenAI.chat_completion(
      model: "gpt-3.5-turbo",
      messages: [
            %{role: "system", content: "You are a helpful assistant."},
            %{role: "user", content: "Who won the world series in 2020?"},
            %{role: "assistant", content: "The Los Angeles Dodgers won the World Series in 2020."},
            %{role: "user", content: "Where was it played?"}
        ]
    )
  """
  def do_chat(:chatable, model_name, msgs) do
    OpenAI.chat_completion(
      model: model_name,
      messages: msgs
    )
  end

  @doc """
    OpenAI.completions(
      "curie:ft-personal-2023-05-05-08-29-09",
      prompt:
      "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.\n\nHuman: Hello, who are you?\nAI: I am an AI created by OpenAI. How can I help you today?\nHuman: What is your favorite color?\nAI:"
      , max_tokens: 10
    )
  """
  def do_chat(model_name, payload, max_tokens \\ 500) do
    OpenAI.completions(
      model_name,
      prompt: payload,
      max_tokens: max_tokens)
  end
end
