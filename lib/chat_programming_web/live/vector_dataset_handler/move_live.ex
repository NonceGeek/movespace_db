defmodule ChatProgrammingWeb.VevtorDatasetHandler.MoveLive do
    use ChatProgrammingWeb, :live_view
  
    @impl true
    def mount(_params, _session, socket) do
      {:ok, socket}
    end
  
    @impl true
    def handle_event(_key, _params, socket) do
      {:noreply, socket}
    end
  
    def handle_params(_params, _url, socket) do
      {:noreply, socket}
    end
  
    @impl true
    def render(assigns) do
      ~H"""
      <.container class="mt-10">
        Hello,World!
      </.container>
      """
    end
  end