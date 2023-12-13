defmodule ChatProgrammingWeb.GalxeLive do
    alias ChatProgramming.{VectorDatasetItem, ArGraphQLInteractor}
    alias ChatProgramming.{ChatServiceInteractor, GreenfieldInteractor}
    alias ChatProgramming.Accounts
    alias MovespaceInteractor.Galxe
    use ChatProgrammingWeb, :live_view

    @dataset_id "galxe-campaigns"

    @impl true
    def mount(params, _session, socket) do
      {:ok, assign(socket,
        alias_name_now: "bnbchain",
        view_form: to_form(%{}, as: :f), 
        searched_already: false
      )}
    end

    @impl true
    def handle_params(_, _uri, socket) do
      {:noreply, socket}
    end

    def get_tx_by_source_and_tx_id(tx_id, "arseeding") do
        ArGraphQLInteractor.query_by_tx_id_arseeding(tx_id)
    end

    def get_tx_by_source_and_dataset_name(dataset_name, "arseeding") do
        ArGraphQLInteractor.query_by_tag_arseeding(%{origin_dataset_name: dataset_name})
    end

    @impl true
    def handle_event(submit_for_search, 
        %{
            "f" => %{"dataset_name" => dataset_name, "freedom_tags" => freedom_tags, "tx_id" => tx_id, "data_source" => data_source}
        }, 
    socket) do
        {:ok, %{data: %{transactions: %{edges: search_result}}}} = 
            cond do
                not (tx_id == "") ->
                    get_tx_by_source_and_tx_id(tx_id, data_source)
                not (dataset_name == "") ->
                    get_tx_by_source_and_dataset_name(dataset_name, data_source)
                # TODO: freedom_tags
                true ->
                    nil
            end

        ar_endpoint = 
            case data_source do
                "arseeding" ->
                    "https://arseed.web3infra.dev"
                "original_arweave" ->
                    "https://arweave.net"
            end
        {
            :noreply, 
            assign(socket,
                search_result: search_result,
                ar_endpoint: ar_endpoint
            )
        }
    end

    @impl true
    def handle_event("add_item_to_item_list", %{"tags" => tags, "tx-id" => tx_id, "endpoint" => endpoint}, socket) do
        item_list = socket.assigns.item_list
        item_list = item_list ++ [%{tags: Poison.decode!(tags), tx_id: tx_id, endpoint: endpoint}]
        {:noreply, 
            assign(socket,
                item_list: item_list
            )
        }
    end

    @impl true
    def handle_event("save_change", %{"_target" => ["f", "alias_name"], "f" => %{"alias_name" => alias_name}}, socket) do
        {
            :noreply, 
            assign(socket,
                alias_name_now: alias_name
            )
            
        }
    end

    @impl true
    def handle_event("view_data", %{"f" => %{"alias_name" => alias_name}}, socket) do
        {:ok, %{result: %{data: %{space: %{alias: "bnbchain", campaigns: %{list: payload}}}}}} = 
            Galxe.query_campaign_list(
                Constants.movespace_endpoint,
                alias_name
            )
        {
            :noreply, 
            assign(socket,
                search_result: payload
            )
        }
    end

    @impl true
    def handle_event("to_vector", %{"item-id" => item_id, "item-name" => item_name}, socket) do
        res = 
            MovespaceInteractor.insert_data(
                Constants.movespace_endpoint, 
                Constants.movespace_api_key,
                @dataset_id, 
                item_name,
                %{chain: socket.assigns.alias_name_now, item_id: item_id}
            )
        {
            :noreply, 
            socket
            |> put_flash(:info, "#{inspect(res)}")
        }
    end

    @impl true
    def handle_event(others, params, socket) do
        IO.puts others
        IO.puts inspect params
        {:noreply, socket}
    end

    @impl true
    def render(assigns) do
      ~H"""
      <.flash_group flash={@flash} />
      <.container class="mt-10">
        <center>
            <.h2>
                <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
                    Vectorize & Tag the Campaigns, Users, Credentials and more Entities in Galxe.
                </span>
            </.h2>
        </center>
      </.container>


    <.container class="mt-10">  
        <center>
            <.simple_form for={@view_form} phx-submit="view_data" phx-change="save_change">
                <.text_input form={@view_form} field={:alias_name} value={@alias_name_now}/>                
                <.button  color="secondary" label="View Data!" variant="outline" />
            </.simple_form>
            <br><hr><br>

            <%= if not is_nil(assigns[:search_result]) do %>
                <.h5>Result from Galxe</.h5>
                <.table>
                    <thead>
                    <.tr>
                        <.th>id</.th>
                        <.th>name</.th>
                        <.th>vectorize</.th>
                        <.th>tag</.th>
                    </.tr>
                    </thead>
                    <tbody>   
                        <%= for item <- assigns[:search_result] do %>
                        <.tr>
                            <.td><%= item.id %></.td>
                            <.td><%= item.name %></.td>
                            <.td><.button phx-value-item_id={item.id} phx-value-item_name={item.name} phx-click="to_vector" color="secondary" label="to vectorDB" variant="outline" /></.td>
                            <.td>
                                <a href="https://galxe-campaigns.vercel.app" target="_blank">
                                    <.button color="secondary" label="tag Item" variant="outline" />
                                </a>
                            </.td>
                        </.tr>
                        <% end %>
                    </tbody>
                </.table>
            <% end %>
        </center>
    </.container>  
      """
    end
  end
