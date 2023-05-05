defmodule ChatProgrammingWeb.ManagerLive do
    alias ChatProgramming.{Space, Card}
    alias ChatProgramming.ChatServiceInteractor
    alias ChatProgramming.Accounts
    use ChatProgrammingWeb, :live_view

    @impl true
    def mount(params, _session, socket) do
      current_user =
        Accounts.preload(socket.assigns.current_user)

      {:ok,
       assign(
         socket,
         current_user: current_user
       )}
    end

    @impl true
    def handle_params(_, _uri, socket) do
      {:noreply, socket}
    end

    @impl true
    def handle_event(_others, params, socket) do
      {:noreply, socket}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <%!-- Only Admin could see manager --%>
      <br><br><br>
      <center>
        <.h2>Hello World!</.h2>
      </center>
      """
    end
  end
