# defmodule ChatProgrammingWeb.Web3DataTaggerLive do
#     alias ChatProgramming.{VectorDatasetItem, ArGraphQLInteractor}
#     alias ChatProgramming.{ChatServiceInteractor, GreenfieldInteractor}
#     alias ChatProgramming.Accounts
#     use ChatProgrammingWeb, :live_view

#     @impl true
#     def mount(params, _session, socket) do
#         vector_dataset_items = 
#             VectorDatasetItem.all()
#             |> Enum.map(fn item ->
#                if is_nil(item.arweave_tx_id) or item.arweave_tx_id == "" do
#                 Map.put(item, :if_upload, false)
#                else
#                 Map.put(item, :if_upload, true)
#                end
#             end)
#       {:ok, assign(socket,
#         vector_dataset_items: vector_dataset_items,
#         search_form: to_form(%{}, as: :f), 
#         view_form: to_form(%{}, as: :f), 
#         searched_already: false
#       )}
#     end

#     @impl true
#     def handle_params(_, _uri, socket) do
#       {:noreply, socket}
#     end

#     def get_tx_by_source_and_tx_id(tx_id, "arseeding") do
#         ArGraphQLInteractor.query_by_tx_id_arseeding(tx_id)
#     end

#     def get_tx_by_source_and_dataset_name(dataset_name, "arseeding") do
#         ArGraphQLInteractor.query_by_tag_arseeding(%{origin_dataset_name: dataset_name})
#     end

#     @impl true
#     def handle_event(submit_for_search, 
#         %{
#             "f" => %{"dataset_name" => dataset_name, "freedom_tags" => freedom_tags, "tx_id" => tx_id, "data_source" => data_source}
#         }, 
#     socket) do
#         {:ok, %{data: %{transactions: %{edges: search_result}}}} = 
#             cond do
#                 not (tx_id == "") ->
#                     get_tx_by_source_and_tx_id(tx_id, data_source)
#                 not (dataset_name == "") ->
#                     get_tx_by_source_and_dataset_name(dataset_name, data_source)
#                 # TODO: freedom_tags
#                 true ->
#                     nil
#             end

#         ar_endpoint = 
#             case data_source do
#                 "arseeding" ->
#                     "https://arseed.web3infra.dev"
#                 "original_arweave" ->
#                     "https://arweave.net"
#             end
#         {
#             :noreply, 
#             assign(socket,
#                 search_result: search_result,
#                 ar_endpoint: ar_endpoint
#             )
#         }
#     end

#     @impl true
#     def handle_event("add_item_to_item_list", %{"tags" => tags, "tx-id" => tx_id, "endpoint" => endpoint}, socket) do
#         item_list = socket.assigns.item_list
#         item_list = item_list ++ [%{tags: Poison.decode!(tags), tx_id: tx_id, endpoint: endpoint}]
#         {:noreply, 
#             assign(socket,
#                 item_list: item_list
#             )
#         }
#     end

#     @impl true
#     def handle_event("save_change", %{"_target" => ["f", "select_dataset"], "f" => %{"hash" => "", "select_dataset" => select_dataset_now}}, socket) do
#         IO.puts "abcdefg"
#         {
#             :noreply, 
#             assign(socket,
#                 select_dataset_now: select_dataset_now
#             )
            
#         }
#     end

#     @impl true
#     def handle_event("search_data", %{"f" => %{"select_dataset" => dataset_name, "hash" => hash}}, socket) do
#         {:ok, %{similarities: similarities}} = 
#             EmbedbaseInteractor.search_data(dataset_name, hash)

#         hash_fetched = similarities |> Enum.fetch!(0) |> Map.fetch!(:data)
#         if hash_fetched == hash do
#             {
#                 :noreply, 
#                 assign(socket,
#                     search_result: Enum.fetch!(similarities, 0), # because we used as key-value table here, so we just fetch the first one.
#                     select_dataset: dataset_name,
#                     hash: hash,
#                     searched_already: true
#                 )
#             }
#         else
#             {
#                 :noreply, 
#                 assign(socket,
#                     search_result: nil, # because we used as key-value table here, so we just fetch the first one.
#                     select_dataset: dataset_name,
#                     hash: hash,
#                     searched_already: true
#                 )
#             }
#         end
#     end

#     @impl true
#     def handle_event("upload_tx", _params, socket) do
#         tx = socket.assigns.hash
#         dataset_id = socket.assigns.select_dataset
#         res = 
#             MovespaceInteractor.insert_data(
#                 Constants.movespace_endpoint, 
#                 Constants.movespace_api_key,
#                 dataset_id, 
#                 tx,
#                 %{chain: "bnb"}
#             )
#         {
#             :noreply, 
#             socket
#             |> put_flash(:info, "#{inspect(res)}")
#         }
#     end

#     @impl true
#     def handle_event(others, params, socket) do
#         IO.puts others
#         IO.puts inspect params
#         {:noreply, socket}
#     end

#     @impl true
#     def render(assigns) do
#       ~H"""
#       <.flash_group flash={@flash} />
#       <.container class="mt-10">
#         <center>
#             <.h2>
#                 <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
#                     Tag Web3 Data, including Users, Contracts and Transactions
#                 </span>
#             </.h2>
#         </center>
#       </.container>


#     <.container class="mt-10">  
#         <center>
#             <.p>
#                 <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
#                     Select the dataset type:
#                 </span>
#             </.p>
            
#             <.simple_form for={@view_form} phx-submit="search_data" phx-change="save_change">
#                 <.select options={[
#                 "bnb-smart-contracts": "bnb-smart-contracts", 
#                 "bnb-users": "bnb-users", 
#                 "bnb-transactions": "bnb-transactions"
#                 ]} form={@view_form} field={:select_dataset} value={assigns[:select_dataset_now]}/>
#                 <.text_input form={@view_form} field={:hash}/>                
#                 <.button  color="secondary" label="Search!" variant="outline" />
#             </.simple_form>
#             <br><hr><br>
#             <%= if not is_nil(assigns[:search_result]) do %>
#                 <.h5>Items in VectorDB</.h5>
#                 <.table>
#                     <thead>
#                     <.tr>
#                         <.th>uuid</.th>
#                         <.th>hash</.th>
#                         <.th>meatadata</.th>
#                         <.th>tagger</.th>
#                     </.tr>
#                     </thead>
#                     <tbody>
#                     <.tr>
#                         <.td><%= assigns[:search_result][:id] %></.td>
#                         <.td><%= assigns[:search_result][:data] %></.td>
#                         <.td><%= inspect(assigns[:search_result][:metadata]) %></.td>
#                         <.td>
#                         <a href="https://greenfield-eight.vercel.app/debug" target="_blank">
#                             <.button  color="secondary" label="Tag this item!" variant="outline" />
#                         </a>
#                         </.td>
#                     </.tr>
#                     <.tr>
#                         <.td>
#                         <%= if assigns[:select_dataset] == "bnb-transactions" do %>
#                             <.button  color="secondary" label="See full details by chainbase!" variant="outline" />
#                             <!-- todo: impl see data here -->
#                         <% end %>
#                         </.td>
#                     </.tr>
#                     </tbody>

#                 </.table>
#             <% end %>
#             <%= if is_nil(assigns[:search_result]) and (assigns[:searched_already] == true) do %>
#                 <.p>The Tx is not found in dataset, but you can tag it and add it into dataset!</.p>
#                 <.table>
#                     <thead>
#                     <.tr>
#                         <.th>hash</.th>
#                         <.th>meatadata-default</.th>
#                         <.th>tagger</.th>
#                     </.tr>
#                     </thead>
#                 <tbody>
#                 <.tr>
#                     <.td><%= assigns[:hash] %></.td>
#                     <.td><%= inspect(%{"chain": "bnb"}) %></.td>
#                     <.td>

#                     <.button
#                         type="button"
#                         phx-click="upload_tx"
#                         phx-value-ref=""
#                     >
#                         Upload Tx to dataset
#                     </.button>
#                     </.td>
#                 </.tr>
#                 <.tr>
#                     <.td>
#                         <.button color="secondary" label="See full details by chainbase!" variant="outline" />
#                         <!-- todo: impl see data here -->
#                     </.td>
#                 </.tr>
#                 </tbody>

#                 </.table>
#             <% end %>
#         </center>
#     </.container>  
#       """
#     end
#   end
