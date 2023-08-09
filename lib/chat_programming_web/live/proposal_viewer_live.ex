defmodule ChatProgrammingWeb.ProposalViewerLive do
    alias ChatProgramming.Proposal
    use ChatProgrammingWeb, :live_view

    @impl true
    def mount(_params, _session, socket) do
        proposals = Proposal.get_all()
        {:ok, assign(socket,
            proposals: proposals
        )}
    end

    def handle_params(_params, _url, socket) do
        {:noreply, socket}
    end

    @impl true
    def handle_event("check_on_chain_status", params, socket) do
        IO.puts inspect params
        {:noreply, socket}
    end
    @impl true
    def handle_event(_key, _params, socket) do
        {:noreply, socket}
    end

    @impl true
    def render(assigns) do
        ~H"""
            <.container class="mt-10">
                <center>
                    <.p>
                        Open the  
                        <a href="https://noncegeek.github.io/vector-dataset-governancer/" target="_blank" style="color:blue">Governancer dApp</a>, 
                        to submit your proposal
                        <br>
                        Or
                        <br>
                        view  
                        <a href="https://explorer.aptoslabs.com/account/0xacca9ef640d32e344493128bc40dcd5649b18ab3d7b55e0a6d3f5dc6ed4da082/modules/run/governancer/add_voter?network=testnet" target="_blank" style="color:blue">the smart contract</a>.
                    </.p>
                </center>
                <br><hr><br>
                <center><.h3>All Proposals</.h3></center>
                <.table>
                <thead>
                  <.tr>
                    <.th>Title</.th>
                    <.th>Content</.th>
                    <.th>Contributor</.th>
                    <.th>Dataset ID</.th>
                    <.th>If approved?</.th>
                    <.th>Get the On-chain Status</.th>
                  </.tr>
                </thead>
                <tbody>
                <%= for proposal <- assigns[:proposals] do %>
                  <.tr>
                    <.td><%= proposal.title %></.td>
                    <.td><%= proposal.content %></.td>
                    <.td><%= proposal.contributor %></.td>
                    <.td><%= proposal.dataset_id %></.td>
                    <.td><%= proposal.if_approved %></.td>
                    <.td>
                        <a href="https://explorer.aptoslabs.com/account/0xca1fe57768cad929b40d06ad66f87752e11c7f01be485d710ba36215422b2ae0/modules/view/governancer/get_proposal_approve?network=testnet" target="_blank">
                            <.button phx-click="check_on_chain_status" phx-value-proposal_title={proposal.title} class="ml-2">Get!</.button>
                        </a>
                    </.td>
                  </.tr>
                <% end %>
                </tbody>
              </.table> 
            </.container>
        """
    end

end