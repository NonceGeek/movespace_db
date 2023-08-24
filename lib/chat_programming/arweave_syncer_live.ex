defmodule ChatProgrammingWeb.ArweaveSyncerLive do
    alias ChatProgramming.{VectorDatasetItem, ArGraphQLInteractor}
    alias ChatProgramming.ChatServiceInteractor
    alias ChatProgramming.Accounts
    use ChatProgrammingWeb, :live_view

    @impl true
    def mount(params, _session, socket) do
        vector_dataset_items = 
            VectorDatasetItem.all()
            |> Enum.map(fn item ->
               if is_nil(item.arweave_tx_id) or item.arweave_tx_id == "" do
                Map.put(item, :if_upload, false)
               else
                Map.put(item, :if_upload, true)
               end
            end)
      {:ok, assign(socket,
        vector_dataset_items: vector_dataset_items,
        search_form: to_form(%{}, as: :f), 
        item_list: []
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
                    Sync Vector Dataset between Central Server and Arweave Network.
                </span>
            </.h2>
        </center>
      </.container>

      <!-- Areweave Interactor -->

    <.container class="mt-10">  
        <center>
        <.p>
            upload item by dApp powered by everPay
            <a href="https://noncegeek.github.io/Arweave-Vector-Dataset-Uploader-Plugin/#/" target="_blank" style="color:blue">Vector Dataset Uploader</a>, 
        </.p>
        <.p>
            ↓↓↓ Or upload item by <b>custodial account</b> ↓↓↓
        </.p>
        </center>

        <.table>
            <thead>
            <.tr>
                <.th>Unique ID</.th>
                <.th>Context</.th>
                <.th>Arweave Transaction ID</.th>
                <.th>Origin Dataset Name</.th>
                <.th>Tags</.th>
                <.th>Upload to Arweave</.th>
                <.th>Selected for new VD</.th>
            </.tr>
            </thead>
            <tbody>
            <%= for item <- assigns[:vector_dataset_items] do %>
            <.tr>
                <.td><%= item.unique_id %></.td>
                <.td><%= Binary.take(item.context, 30) <> "..." %></.td>
                <.td><%= item.arweave_tx_id %></.td>
                <.td><%= item.origin_dataset_name %></.td>
                <.td> <%= raw(Earmark.as_html!("\n#{Poison.encode!(item.tags, pretty: true)}\n")) %></.td>
                <.td> 
                    <%= if item.if_upload == false do %>
                        <.button color="secondary" label="Upload to Arweave!" type="submit" variant="shadow" />
                    <% else %>
                        <.button disabled color="secondary" label="Uploaded yet" variant="shadow" />
                    <% end %>
                </.td>
                <.td><.checkbox field={:checkbox} /></.td>
            </.tr>
            <% end %>
            </tbody>
        </.table>

        <br><br>
        <center>
            <.h2>
                <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
                    Item Lists.
                </span>
            </.h2>


            <%= if not is_nil(assigns[:item_list]) do %>

                <.table>
                    <thead>
                    <.tr>
                        <.th>Context</.th>
                        <.th>Tags</.th>
                        <.th>Select for new VD</.th>
                    </.tr>
                    </thead>
                    <tbody>
                    <%= for item <- assigns[:item_list] do %>
                    <.td> 
                            <a href={"#{item.endpoint}/#{item.tx_id}"} target="_blank" style="color:blue"> Content </a>
                        </.td>
                        <.td> <%= Poison.encode!(item.tags, pretty: true) %></.td>
                        <.td>
                            <.checkbox field={:checkbox} />
                        </.td>
                    <% end %>
                    </tbody>
                </.table>

            <% end %>
        </center>

        <br><br>
        <center>
            <.h2>
                <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
                    Add Items by Search Arweave Network.
                </span>
            </.h2>
   
        <.p>add items by Dataset Name, tx_id or Freedom Tags, powered by KNN3:</.p>

        <.simple_form for={@search_form} phx-submit="submit_for_search">
            <.p>Data uploaded by?</.p>
            <.select options={[ArSeeding: "arseeding", Original_Arweave: "original_arweave"]} form={@search_form} field={:data_source} />
            <.p>Dataset Name:</.p>
            <.text_input form={@search_form} field={:dataset_name} placeholder="aptos-smart-contracts" />
            <br>
            <.p>Tx ID:</.p>
            <.text_input form={@search_form} field={:tx_id} placeholder="tx-id" />
            <br>
            <.p>Freedom Tags:</.p>
            <.text_input form={@search_form} field={:freedom_tags} placeholder="freedom-tags" />
            <br>
            <.button  color="secondary" label="Search!" variant="outline" />
        </.simple_form>
        <br>
        <%= if not is_nil(assigns[:search_result]) do %>

            <.table>
                <thead>
                <.tr>
                    <.th>Context</.th>
                    <.th>Tags</.th>
                    <.th>Add item to Item List</.th>
                </.tr>
                </thead>
                <tbody>
                <%= for item <- assigns[:search_result] do %>
                    <.td> 
                        <a href={"#{assigns[:ar_endpoint]}/#{item.node.id}"} target="_blank" style="color:blue"> Content </a>
                    </.td>
                    <.td> <%= Poison.encode!(item.node.tags, pretty: true) %></.td>
                    <.td>
                        <.button  color="secondary" label="Add item to the Item List" phx-click="add_item_to_item_list" phx-value-endpoint={assigns[:ar_endpoint]} phx-value-tx_id={item.node.id} phx-value-tags={Poison.encode!(item.node.tags)} variant="outline" />
                    </.td>
                <% end %>
                </tbody>
            </.table>

        <% end %>


        <br><br>
            <.p>New Vector Dataset Name:</.p>
            <.text_input placeholder="new-vector-dataset" />
            <br>
            <.button  color="secondary" label="Generate New Vector Datasets by the Selected!"  variant="outline" />
        </center>
    </.container>  
      """
    end
  end
