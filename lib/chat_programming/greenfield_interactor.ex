defmodule ChatProgramming.GreenfieldInteractor do

    @moduledoc """
        Interact with greenfield storage.
        js sdk docs:
        > https://docs.bnbchain.org/greenfield-js-sdk/api/object#listobjects-
        api docs:
        > https://docs.bnbchain.org/greenfield-docs/docs/api/storage-provider-rest/list_objects_by_bucket
    """
    # +---------------+
    # | vector syncer |
    # +---------------+

    def fetch_vector_db(:index, endpoint, bucket_name) do
       fetch_file(endpoint, bucket_name, "indexer.json")
    end

    def fetch_vector_db(vector_or_not, greenfield_endpoint, greenfield_sp_endpoint, bucket_name) do
        # TODO: fetch more files by the index
        {[first_file_name], others} = 
            vector_or_not
            |> fetch_vector_db_file_list(greenfield_endpoint, bucket_name)
            |> Enum.split(1)
        fetch_file(greenfield_sp_endpoint, bucket_name, first_file_name)
    end
    @doc """
        fetch vectorDB exclude vector info in a bucket
    """
    def fetch_vector_db_file_list(:no_vector, endpoint, bucket_name) do
        # get_name_list
        endpoint
        |> fetch_object_list(bucket_name)
        |> Enum.filter(fn obj_name -> String.ends_with?(obj_name, ".csv") end)
        |> Enum.reject(fn obj_name -> String.contains?(obj_name, "vector") end)
    end

    def fetch_vector_db_file_list(:vector, endpoint, bucket_name) do
        # get_name_list
        endpoint
        |> fetch_object_list(bucket_name)
        |> Enum.filter(fn obj_name -> String.ends_with?(obj_name, ".csv") end)
        |> Enum.filter(fn obj_name -> String.contains?(obj_name, "vector") end)
    end

    # +-----------------+
    # | basic functions |
    # +-----------------+
    def build_path(endpoint, bucket_name, file_name) do
        "#{endpoint}/view/#{bucket_name}/#{file_name}"
    end

    # TODO: List bucket by acct.

    @doc """
        fetch object list by bucket name.
        path: 
        > {endpoint}/greenfield/storage/list_objects/{bucket_name}
        for example:
        > https://greenfield-chain-us.bnbchain.org/greenfield/storage/list_objects/all-whitepapers
        see in:
        > proto/greenfield/storage/query.proto
        
    """
    def fetch_object_list(endpoint, bucket_name) do
        {:ok,
            %{
            object_infos: object_infos
            }
        } =
        endpoint
        |> build_fetch_object_list_path(bucket_name)
        |> ExHttp.http_get()
        Enum.map(object_infos, fn %{object_name: object_name} -> object_name end)
    end

    def build_fetch_object_list_path(endpoint, bucket_name) do
        "#{endpoint}/greenfield/storage/list_objects/#{bucket_name}"
    end

    @doc """
        A example:
        > GreenfieldInteractor.fetch_file("https://gnfd-testnet-sp3.bnbchain.org", "all-whitepapers", "indexer.json")
    """
    def fetch_file(endpoint, bucket_name, file_name) do
        endpoint
        |> build_path(bucket_name, file_name)
        |> ExHttp.http_get()
    end
end