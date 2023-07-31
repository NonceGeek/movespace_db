defmodule ChatProgramming.GovernancerInteractor do
    @moduledoc """
        See Examples in Web3_Aptos_Ex
    """
    alias Web3AptosEx.Aptos.RPC
    import Web3AptosEx.Aptos
    alias Web3AptosEx.Aptos
    
    @contract_addr "0xca1fe57768cad929b40d06ad66f87752e11c7f01be485d710ba36215422b2ae0"

    @resources %{
        voters: "#{@contract_addr}::governancer::Voters",
        proposal_set: "#{@contract_addr}::governancer::ProposalSet",
        proposal: "#{@contract_addr}::governancer::Proposal",
    }

    @table_handles %{
        proposal_map: "0x1488dfa4e509768e63039f0f9b929fb5b8319556e52123fb301fdde42e197ab1"
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
        with {:ok, result} <- Web3AptosEx.Aptos.get_table_item(
            client,
            @table_handles.proposal_map,
            "0x1::string::String",
            @resources.proposal,
            index
        ) do
            result
        end
    end

    def get_proposal_approve(client, proposal_title) do
    end

    def get_proposal_deny(client, proposal_title) do
    end

    def transfer(client, acct, to, amount) do
      {:ok, f} = ~a"0x1::coin::transfer<CoinType>(address, u64)"
      payload = Aptos.call_function(f, ["0x1::aptos_coin::AptosCoin"], [to, amount])
      Aptos.submit_txn(client, acct, payload)
    end
    
end