NimbleCSV.define(CSVParser, separator: ",", escape: "\"")

defmodule ChatProgrammingWeb.GreenfieldTaggerLive do
    alias ChatProgramming.{VectorDatasetItem, ArGraphQLInteractor}
    alias ChatProgramming.{ChatServiceInteractor, GreenfieldInteractor}
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
        data_viewer_form: to_form(%{}, as: :f), 
        item_list: [],
        bucket_name_now: "all-whitepapers"
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
    def handle_event("save_change", %{"_target" => ["f", "bucket_name"], "f" => %{"bucket_name" => bucket_name}}, socket) do
        socket = assign(socket, bucket_name_now: bucket_name)
        {:noreply, socket}
    end

    @impl true
    def handle_event("view_data", %{"f" => %{"bucket_name" => bucket_name}}, socket) do
        # TODO: fetch data by bucket name
        {
            :ok, 
            indexer
        } = GreenfieldInteractor.fetch_vector_db(:index, Constants.greenfield_sp_endpoint(), bucket_name)
        {
            :ok,
            vector_data
        } = GreenfieldInteractor.fetch_vector_db(
            :no_vector, 
            Constants.greenfield_endpoint(), 
            Constants.greenfield_sp_endpoint(), 
            bucket_name
        )

        vector_data = CSVParser.parse_string(vector_data)
        {
            :noreply, 
            assign(socket,
                indexer: indexer,
                data: vector_data
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
                    Tag the data in the Buckets on the Greenfield.
                </span>
            </.h2>
        
        <.p>TODO: here is a pic to describe the process.</.p>
        <.p><a href="https://dcellar.io/" style="color: blue;" target="_blank">want to upload files to greenfield?</a></.p>
        </center>
      </.container>


    <.container class="mt-10">  
        <center>
            <.h2>
                <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
                    View Data Items in Bucket.
                </span>
            </.h2>

            <.simple_form for={@data_viewer_form} phx-submit="view_data" phx-change="save_change">
                <.text_input form={@data_viewer_form} field={:bucket_name} value={assigns[:bucket_name_now]} placeholder="all-whitepapers" />
                <.button  color="secondary" label="Read!" variant="outline" />
            </.simple_form>
            <br><hr><br>
            <%= if not is_nil(assigns[:indexer]) do %>
                <%= Enum.map(assigns[:indexer], fn {key, value} -> %>
                    <.p><b><%= key %></b>: <%= inspect(value) %></.p>
                <%= end) %>
            <% end %>
            <br><hr><br>
            <.p></.p>
            <%= if not is_nil(assigns[:data]) do %>
                <.h5>Items in VectorDB</.h5>
                <.table>
                    <thead>
                    <.tr>
                        <.th>id</.th>
                        <.th>uuid</.th>
                        <.th>content</.th>
                        <.th>metadata</.th>
                        <.th>Tag items</.th>
                    </.tr>
                    </thead>
                    <tbody>
                    <%= for [id, uuid, data, metadata] <- assigns[:data] do %>
                        <.tr>
                        <.td><%= id %></.td>
                        <.td><%= uuid %></.td>
                        <.td><%= data %></.td>
                        <.td><%= metadata %></.td>
                        <.td>
                            <a href={assigns[:indexer].tagger_dapp} target="_blank">
                                <.button  color="secondary" label="Tag this item!" variant="outline" />
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
