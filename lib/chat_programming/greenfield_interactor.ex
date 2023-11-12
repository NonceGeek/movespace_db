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

    @doc """
        fetch count in a bucket
    """
    def fetch_vector_db(:count, endpoint, bucket_name) do
        endpoint
        |> fetch_object_list(bucket_name)
        |> Enum.filter(fn obj_name -> String.ends_with?(obj_name, ".csv") end)
        # filter all the csv files.
        |> Enum.count()
    end

    def fetch_vector_db(:data, endpoint, bucket_name, indexer) do
        # fetch all the data, which means file end with "csv".
        obj_name = 
            endpoint
            |> fetch_object_list(bucket_name)
            |> Enum.filter(fn obj_name -> String.ends_with?(obj_name, ".csv") end)
            |> Enum.fetch!(indexer)
        fetch_file(endpoint, bucket_name, obj_name)
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
    """
    def fetch_object_list(endpoint, bucket_name) do
        # TODO: the API is somethings wrong, so mock it now.
        ["indexer.json", "all-whitepapers.csv"]
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