defmodule ChatProgrammingWeb.MessageListComponent do
  alias ChatProgrammingWeb.MessageComponent
  alias ChatProgrammingWeb.Message
  use ChatProgrammingWeb, :live_component

  attr :messages, :list, required: true

  def render(assigns) do
    ~H"""
    <div class="my-4 relative h-full w-full transition-width flex flex-col overflow-hidden items-stretch flex-1">
      <%= for message <- @messages |> Enum.filter(& &1.content != "") do %>
        <.live_component
          module={MessageComponent}
          id={message.id}
          message={message.content}
          sender={message.sender}
        />
      <% end %>
    </div>
    """
  end
end
