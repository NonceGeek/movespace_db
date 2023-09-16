defmodule ChatProgramming.EmbedbaseUploader do
    require Logger

    def get_all_json(file_path) do
        Path.wildcard("data_resources/#{file_path}/**/*.json")
    end

    def read_file(file_path, file_name) do
        {:ok, raw} = File.read("data_resources/#{file_path}/#{file_name}.json")
        Poison.decode!(raw)
    end

    def upload(dataset_id, file_path, file_name, source_url) do
        # get all the keys
        contract_json = read_file(file_path, file_name)
        contract_json
        |> Enum.map(fn {type, _} ->
            type
        end)
        |> Enum.map(fn type ->
            upload_by_type(dataset_id, type, file_path, file_name, source_url)
        end)
    end

    def upload_by_type(dataset_id, type, file_path, file_name, source_url) do
        contract_json = read_file(file_path, file_name)
        items = Map.fetch!(contract_json, type)
        Enum.map(items, fn item ->
            EmbedbaseInteractor.insert_data(
                dataset_id, 
                item,  
                %{type: type, file_name: file_name, source_url: source_url, file_path: file_path}
            )
        end)
    end

    def upload_by_type(dataset_id, type, file_name, source_url) do
        contract_json = read_file(file_name, file_name)
        items = Map.fetch!(contract_json, type)
        Enum.each(items, fn item ->
            res = EmbedbaseInteractor.insert_data(
                dataset_id, 
                item,  
                %{type: type, file_name: file_name, source_url: source_url}
            )
            Logger.info("#{inspect(res)}")
        end)
    end
end