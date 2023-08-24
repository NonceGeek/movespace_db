defmodule ChatProgrammingWeb.ArweaveQuerierLive do
    alias ChatProgramming.{VectorDatasetItem, ArGraphQLInteractor}
    alias ChatProgramming.ChatServiceInteractor
    alias ChatProgramming.Accounts
    use ChatProgrammingWeb, :live_view

    @impl true
    def mount(%{"tx_id" => tx_id}, _session, socket) do
      {:ok, tx} = ArGraphQLInteractor.query_by_tx_id_arseeding(tx_id)
      {:ok, assign(socket,
        tx: tx
      )}
    end

    def mount(tags, _session, socket) do
      {:ok, tx} = ArGraphQLInteractor.query_by_tag_arseeding(tags)
      {:ok, assign(socket,
        tx: tx
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
        <.flash_group flash={@flash} />

        <%= if is_nil(assigns[:tx]) == false do %>
          <.container class="mt-10">
              <%= raw(Earmark.as_html!("```\n#{Poison.encode!(@tx, pretty: true)}\n```")) %>
          </.container>  
        <% end %>
        """
    end
  end
