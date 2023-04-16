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
  def handle_params(params, _uri, socket) do
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
    } = ChatServiceInteractor.chat(question)
    IO.puts inspect answer
    IO.puts inspect history
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
          Chat Programming
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
          <div class="flex items-start">
            <.alert color="info" label="Give me a programming exercise on Python data structures." />
          </div>
          <div class="flex items-start mt-4">
            <.alert color="success" label="Give me an exercise on if statements in Python." />
          </div>
          <div class="flex items-start mt-4">
            <.alert color="warning" label="Give me an exercise on the for statement in Python." />
          </div>
          <% end %>
        </div>
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

      <.container class="mt-10">
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
      </.container>
    </.form>
    """
  end
end
