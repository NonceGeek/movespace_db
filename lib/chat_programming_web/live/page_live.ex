defmodule ChatProgrammingWeb.PageLive do
  alias ChatProgramming.{Space, Card}
  alias ChatProgramming.ChatServiceInteractor
  use ChatProgrammingWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    spaces = Space.all()
    space_names = Enum.map(spaces, & &1.name)
    space_selected = Enum.at(spaces, 0)

    {:ok,
     assign(
       socket,
       form: to_form(%{}, as: :f),
       # spaces
       space_names: space_names,
       spaces: spaces,
       space_selected: space_selected
     )}
  end

  @impl true
  def handle_params(%{"q" => "1"}, _uri, socket) do
    answer = "Sure! Here's a programming exercise on Python data structures:

Write a Python program that takes in a list of integers and returns the largest and smallest numbers in the list.

Here's an example of how the program should work:

```
Input: [4, 2, 7, 1, 9, 5]
Output: Largest number is 9, smallest number is 1
```

To solve this exercise, you'll need to use Python's built-in list data structure and the max and min functions. Here's an example solution:

```
def largest_and_smallest(numbers):
    largest = max(numbers)
    smallest = min(numbers)
    return Largest number is {largest}, smallest number is {smallest}
```

You can then call the function with a list of integers as an argument:

```
numbers = [4, 2, 7, 1, 9, 5]
print(largest_and_smallest(numbers))
```

This should output:

```
Largest number is 9, smallest number is 1
```

You can modify the input list to test the function with different values. Good luck!
"
    history =  ["", "Human: how can I begin to learn python?",
    "Bot: Learning Python is a great choice! Here are some steps you can take to get started:

    Install Python: You can download and install the latest version of Python from the official Python website (https://www.python.org/downloads/).

    Choose a learning resource: There are many online resources available for learning Python, including websites, tutorials, books, and video courses. Some popular options include Codecademy, Udemy, Coursera, and edX.

    Learn the basics: Begin by learning the basics of Python syntax, data types, and control structures. This will provide a foundation for more advanced concepts later on.

    Practice coding: As with any programming language, the best way to learn Python is by writing code. Start with simple exercises and gradually work your way up to more complex programs.

    Join a community: There are many online communities for Python learners and developers, including forums, social media groups, and online meetups. Joining a community can provide support, advice, and opportunities to collaborate with others.

    Remember to take your time, be patient, and enjoy the process of learning Python!"]
    {
      :noreply, assign(socket,
      answer: answer,
      history: handle_history(history)
      )
  }
  end

  def handle_params(%{"q" => "2"}, _uri, socket) do
    answer = "Sure, here's an exercise on if statements in Python:

Write a Python program that takes in an integer and checks if it is even or odd. If the integer is even, the program should print 'The number is even.' If the integer is odd, the program should print The number is odd.

Here's an example of how the program should work:

```
Input: 6
Output: The number is even.
```

And another example:

```
Input: 3
Output: The number is odd.
```

To solve this exercise, you'll need to use an if statement to check if the input integer is even or odd. You can use the modulo operator % to determine if a number is even or odd. If a number is even, it will have a remainder of 0 when divided by 2. If a number is odd, it will have a remainder of 1 when divided by 2.

Here's an example solution:

```
def even_or_odd(number):
    if number % 2 == 0:
        print('The number is even.')
    else:
        print('The number is odd.')
```

You can then call the function with an integer as an argument:

```
number = 6
even_or_odd(number)
```

This should output:

```
The number is even.
```

You can modify the input integer to test the function with different values. Good luck!
"

history =  ["", "Human: how can I begin to learn python?",
    "Bot: Learning Python is a great choice! Here are some steps you can take to get started:

    Install Python: You can download and install the latest version of Python from the official Python website (https://www.python.org/downloads/).

    Choose a learning resource: There are many online resources available for learning Python, including websites, tutorials, books, and video courses. Some popular options include Codecademy, Udemy, Coursera, and edX.

    Learn the basics: Begin by learning the basics of Python syntax, data types, and control structures. This will provide a foundation for more advanced concepts later on.

    Practice coding: As with any programming language, the best way to learn Python is by writing code. Start with simple exercises and gradually work your way up to more complex programs.

    Join a community: There are many online communities for Python learners and developers, including forums, social media groups, and online meetups. Joining a community can provide support, advice, and opportunities to collaborate with others.

    Remember to take your time, be patient, and enjoy the process of learning Python!"]
    {
      :noreply, assign(socket,
      answer: answer,
      history: handle_history(history)
      )
  }
  end

  def handle_params(_, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", params, socket) do
    %{f: %{question: question}} = ExStructTranslator.to_atom_struct(params)

    # interact with ChatService
    {
      :ok,
      %{
        code: 0,
        data:
        %{
          answer: answer,
          history: history
        },
        msg: "success"
      }
    } = ChatServiceInteractor.mock_chat(question)
    {
      :noreply,
      assign(
        socket,
        answer: answer,
        history: handle_history(history)
      )
    }
  end

  def handle_history(history_list) do
    history_list
    |> Enum.map(fn history ->
      case history do
        "" ->
          history
        others ->
          case String.at(history, 0) do
            "H" ->
              "**Question:** " <> Binary.drop(history, 6)
            "B" ->
              "**Answer:** " <> Binary.drop(history, 4)
            others ->
              history
          end
      end
    end)
    |> Enum.drop(1)
  end

  def handle_event(
        "change_space",
        %{"_target" => ["f", "space_name"], "f" => %{"space_name" => space_name}} = params,
        %{assigns: assigns} = socket
      ) do
    space_selected = Space.get_by_name(space_name)

    {
      :noreply,
      socket
      |> assign(space_selected: space_selected)
    }
  end

  def handle_event(_others, params, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container class="mt-10">
      <.h1>
        <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
          Self-Learning Programming by Chat
        </span>
      </.h1>
      <.h5>Chat to learning anything about programming.</.h5>
    </.container>

    <.form for={@form} phx-change="change_space" phx-submit="submit">
      <.container class="mt-10 mb-32">
        <.h3 label="" />
        <div>
          <.input field={@form[:space_name]} type="select" options={@space_names} />
          <br />
          <.h5><%= @space_selected.description %></.h5>
          <br />
          <.input field={@form[:question]} placeholder="How can I learn this technical?" />
          <br />
          <.button color="pure_white" label="Get Answer ⏎" />
          <br><br>
          <%= if is_nil(assigns[:answer]) do %>
            <.h5>Waiting for answer...</.h5>
          <% else %>
            <.h5><%= raw(Earmark.as_html!(assigns[:answer])) %></.h5>
          <% end %>

          <br><br>
          <%= if is_nil(assigns[:history]) do %>
          <% else %>
          <.h5 label="Chat History" />
            <div class="p-1 mt-5 overflow-auto">
              <.table>
                <thead>
                  <.tr>
                    <.th>Histories</.th>
                  </.tr>
                </thead>
                <tbody>
                  <%= for history <- assigns[:history] do %>
                    <.tr>
                      <.td>
                        <%= raw(Earmark.as_html!(history))%>
                      </.td>
                    </.tr>
                  <% end %>
                </tbody>
              </.table>
            </div>
          <br><br>
          <.h5>The Questions that recommend: </.h5>
          <a href="/?q=1">
            <div class="flex items-start">
              <.alert color="info" label="Give me a programming exercise on Python data structures." />
            </div>
          </a>
          <a href="/?q=2">
          <div class="flex items-start mt-4">
            <.alert color="success" label="Give me an exercise on if statements in Python." />
          </div>
          </a>
          <a href="/?q=2">
          <div class="flex items-start mt-4">
            <.alert color="warning" label="Give me an exercise on the for statement in Python." />
          </div>
          </a>
          <% end %>
        </div>
      </.container>

      <.container class="mt-10">
        <.h2 underline label="Question Recommended" />
          <a href="/?q=1">
          <div class="flex items-start mt-4">
            <.alert color="info" label="As a fresh man, how could I learn this technical?" />
          </div>
          </a>
          <a href="/?q=2">
          <div class="flex items-start mt-4">
            <.alert color="success" label="Recommend a real project where I can learn this technique." />
          </div>
          </a>
          <a href="/?q=3">
            <div class="flex items-start mt-4">
              <.alert color="warning" label="Recommand the bounties that I can do." />
            </div>
          </a>
      </.container>

      <.container class="mt-10">
        <.h2 underline label="Knowledge Cards" />
        <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-3">
          <%= for card <- @space_selected.card do %>
            <a href={"#{card.url}"} target="_blank">
              <.card variant="outline">
                <.card_content category={"#{@space_selected.name}"} heading={"#{card.title}"}>
                  <%= card.context %>
                </.card_content>
              </.card>
            </a>
          <% end %>
        </div>
      </.container>

      <!--<.container class="mt-10">
        <.h2 underline label="Experts Recommandation" />
        <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-3">
          <%= for expert <- @space_selected.expert do %>
            <a href={"#{expert.url}"} target="_blank">
              <.card variant="outline">
                <.card_content category={"#{@space_selected.name}"} heading={"#{expert.name}"}>
                  <.avatar
                    size="xl"
                    src="https://res.cloudinary.com/wickedsites/image/upload/v1604268092/unnamed_sagz0l.jpg"
                  />
                  <br>
                  <%= expert.description %>
                </.card_content>
              </.card>
            </a>
          <% end %>
        </div>
      </.container>-->
    </.form>
    """
  end
end
