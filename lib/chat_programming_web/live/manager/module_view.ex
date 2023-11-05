defmodule ChatProgrammingWeb.Manager.ModuleViewLive do
    alias ChatProgramming.{Space, Card}
    alias ChatProgramming.ChatServiceInteractor
    alias ChatProgramming.Accounts
    alias ChatProgramming.ModelHandler
    use ChatProgrammingWeb, :live_view

    @impl true
    def mount(params, _session, socket) do
      current_user =
        Accounts.preload(socket.assigns.current_user)

      models =
        ModelHandler.all()
      {:ok,
       assign(
        socket,
        current_user: current_user,
        models: models
       )}
    end

    @impl true
    def handle_params(_, _uri, socket) do
      {:noreply, socket}
    end

    @impl true
    def handle_event("chat_with_model", %{"model-id" => model_id}, socket) do

      {
        :noreply,
        socket
        |> push_navigate(to: "/")
      }
    end

    @impl true
    def handle_event(others, params, socket) do
      IO.puts inspect others
      IO.puts inspect params
      {:noreply, socket}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <br><br><br>
      <center>
        <.table>
            <thead>
              <.tr>
                <.th>Model Name</.th>
                <.th>Create Engine?</.th>
                <.th>Fine Tuning?</.th>
                <.th>Logprobs?</.th>
                <.th>Search Indices?</.th>
                <.th>View?</.th>
                <.th>Blocking?</.th>
                <.th>Chat with this model</.th>
              </.tr>
            </thead>
            <tbody>
              <%= for models <- @models do %>
                <.tr>
                  <% permission = models.permission |> Enum.fetch!(0) %>
                  <.td><%= models.id %></.td>
                  <.td><%= permission|> Map.fetch!(:allow_create_engine) %></.td>
                  <.td><%= permission |> Map.fetch!(:allow_fine_tuning) %></.td>
                  <.td><%= permission |> Map.fetch!(:allow_logprobs) %></.td>
                  <.td><%= permission |> Map.fetch!(:allow_search_indices) %></.td>
                  <.td><%= permission |> Map.fetch!(:allow_view) %></.td>
                  <.td><%= permission |> Map.fetch!(:is_blocking) %></.td>
                  <.td>
                    <a target="_blank" href={"/chatter?model_name=#{models.id}&topic=Programming"}>
                      <.button color="success" label="Chat"/>
                    </a>
                  </.td>
                </.tr>
              <% end %>
            </tbody>
          </.table>
      </center>
      """
    end
  end
