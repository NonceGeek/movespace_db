defmodule ChatProgrammingWeb.Manager.ModuleViewLive do
    alias ChatProgramming.{Space, Card}
    alias ChatProgramming.ChatServiceInteractor
    alias ChatProgramming.Accounts
    use ChatProgrammingWeb, :live_view

    @impl true
    def mount(params, _session, socket) do
      current_user =
        Accounts.preload(socket.assigns.current_user)

      {:ok, %{data: models}} =
        OpenAI.models()
      models_atomed = ExStructTranslator.to_atom_struct(models)
      {:ok,
       assign(
        socket,
        current_user: current_user,
        models: models_atomed
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
                </.tr>
              <% end %>
            </tbody>
          </.table>
      </center>
      """
    end
  end
