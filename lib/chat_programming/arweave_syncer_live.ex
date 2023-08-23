defmodule ChatProgrammingWeb.ArweaveSyncerLive do
    alias ChatProgramming.VectorDatasetItem
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
        vector_dataset_items: vector_dataset_items
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
            </.tr>
            </thead>
            <tbody>
            <%= for item <- assigns[:vector_dataset_items] do %>
            <.tr>
                <.td><%= item.unique_id %></.td>
                <.td><%= Binary.take(item.context, 30) <> "..." %></.td>
                <.td><%= item.arweave_tx_id %></.td>
                <.td><%= item.origin_dataset_name %></.td>
                <.td><%= inspect(item.tags) %></.td>
                <.td> 
                    <%= if item.if_upload == false do %>
                        <.button color="secondary" label="Upload to Arweave!" type="submit" variant="shadow" />
                    <%= else %>
                        <.button color="secondary" label="Uploaded yet" type="submit" variant="shadow" />
                    <% end %>
                </.td>
            </.tr>
            <% end %>
            </tbody>
        </.table>
    </.container>  
      """
    end
  end
