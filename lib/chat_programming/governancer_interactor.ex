defmodule ChatProgramming.GovernancerInteractor do
    @moduledoc """
        See Examples in Web3_Aptos_Ex
    """
    alias Web3AptosEx.Aptos.RPC
    import Web3AptosEx.Aptos
    alias Web3AptosEx.Aptos
    
    @contract_addr "0xacca9ef640d32e344493128bc40dcd5649b18ab3d7b55e0a6d3f5dc6ed4da082"

    @resources %{
        voters: "#{@contract_addr}::governancer::Voters",
        proposal_set: "#{@contract_addr}::governancer::ProposalSet",
        proposal: "#{@contract_addr}::governancer::Proposal",
    }

    def get_voters(client) do
      with {:ok, result} <- RPC.get_resource(
        client,
        @contract_addr,
        @resources.voters) do
        result.data
      end
    end

    def get_proposal_set(client) do
        with {:ok, result} <- RPC.get_resource(
            client,
            @contract_addr,
            @resources.proposal_set) do
            result.data
        end
    end
    
    def get_proposal_index(client) do
        client
        |> get_proposal_set()
        |> Map.fetch!(:titles)
    end

    def get_proposal_by_index(client, index) do
        %{proposal_map: %{handle: proposal_map}} = get_proposal_set(client)
        with {:ok, result} <- Web3AptosEx.Aptos.get_table_item(
            client,
            proposal_map,
            "0x1::string::String",
            @resources.proposal,
            index
        ) do
            result
        end
    end

    def get_proposal_approve(client, proposal_title) do
        Web3AptosEx.Aptos.call_view_func(client, "#{@contract_addr}::governancer::get_proposal_approve", [], [proposal_title])

    end

    def get_proposal_deny(client, proposal_title) do
        Web3AptosEx.Aptos.call_view_func(client, "#{@contract_addr}::governancer::get_proposal_deny", [], [proposal_title])
    end

    def transfer(client, acct, to, amount) do
      {:ok, f} = ~a"0x1::coin::transfer<CoinType>(address, u64)"
      payload = Aptos.call_function(f, ["0x1::aptos_coin::AptosCoin"], [to, amount])
      Aptos.submit_txn(client, acct, payload)
    end
    
end