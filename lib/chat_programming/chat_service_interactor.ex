defmodule ChatProgramming.ChatServiceInteractor do
  @default_url "http://localhost:5000"

  @doc """
    see pricing in: https://openai.com/pricing

    see model list in: https://platform.openai.com/docs/models/gpt-3-5

    > gpt-3.5-turbo: $0.002 / 1K tokens
  """
  @default_module_name "gpt-3.5-turbo"
  @default_chat_space "programming"
  def build_path(:chat), do: "#{@default_url}/chat"
  def build_path(:train), do: "#{@default_url}/train"

  def mock_chat(question) do
    {:ok,
    %{
      code: 0,
      data: %{
        answer: " Hi there! I'm doing great, thanks for asking. How can I help you today?",
        history: ["", "Human: how are you?",
         "Bot:  Hi there! I'm doing great, thanks for asking. How can I help you today?"]
      },
      msg: "success"
    }}
  end

  def chat(question, space_name \\ @default_chat_space, module_name \\ @default_module_name) do
    url = build_path(:chat)
    data =build_body(:chat, question, space_name, module_name)
    ExHttp.http_post(url, data)
  end

  def mock_train(file_list) do
    {:ok,
    %{
      code: 0,
      data: %{
        index_space_size: 6.0439,
        pkl_space_size: 2.4092,
        size_type: "kb",
        space_name: "programming"
      },
      msg: "success"
    }}
  end

  def train(file_list, space_name \\ @default_chat_space, file_tag \\ :local) when is_list(file_list) do
    url = build_path(:train)
    data = build_body(:train, file_list, space_name, file_tag)
    ExHttp.http_post(url, data)
  end



  def build_body(:chat, question, space_name, module_name) do
    %{
      question: question,
      space_name: space_name,
      model_name: module_name,
      history: [""]
    }
  end

  def build_body(:train, file_list, space_name, file_tag) do
    %{
      file_list: file_list,
      space_name: space_name,
      file_tag: file_tag
    }
  end
end
