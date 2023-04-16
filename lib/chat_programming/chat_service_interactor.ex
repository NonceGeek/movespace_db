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
        answer: "Sure, here's a programming exercise that involves using the Python String data type:
Write a Python program that asks the user to enter a string of text, and then performs the following operations on the string:

0x1) Count the number of characters in the string.

0x2) Count the number of words in the string.

0x3) Count the number of sentences in the string.

0x4) Reverse the string.

0x5) Convert the string to uppercase.

0x6) Convert the string to lowercase.

Your program should output the results of each operation on the string.

Here's an example of what the output of the program might look like:

```Python
  Enter a string of text: The quick brown fox jumps over the lazy dog.

  Number of characters: 44
  Number of words: 9
  Number of sentences: 1
  Reversed string: .god yzal eht revo spmuj xof nworb kciuq ehT
  Uppercase string: THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.
  Lowercase string: the quick brown fox jumps over the lazy dog.
```
        ",
        history: ["", "Human: how can I begin to learn python?",
"Bot: Learning Python is a great choice! Here are some steps you can take to get started:

Install Python: You can download and install the latest version of Python from the official Python website (https://www.python.org/downloads/).

Choose a learning resource: There are many online resources available for learning Python, including websites, tutorials, books, and video courses. Some popular options include Codecademy, Udemy, Coursera, and edX.

Learn the basics: Begin by learning the basics of Python syntax, data types, and control structures. This will provide a foundation for more advanced concepts later on.

Practice coding: As with any programming language, the best way to learn Python is by writing code. Start with simple exercises and gradually work your way up to more complex programs.

Join a community: There are many online communities for Python learners and developers, including forums, social media groups, and online meetups. Joining a community can provide support, advice, and opportunities to collaborate with others.

Remember to take your time, be patient, and enjoy the process of learning Python!"]
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
