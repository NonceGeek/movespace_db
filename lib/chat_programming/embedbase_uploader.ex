defmodule ChatProgramming.EmbedbaseUploader do
    require Logger

    def get_all_json(file_path) do
        Path.wildcard("data_resources/#{file_path}/**/*.json")
    end

    def read_file(file_path, file_name) do
        {:ok, raw} = File.read("data_resources/#{file_path}/#{file_name}.json")
        Poison.decode!(raw)
    end

    def upload(dataset_id, type, file_path, file_name) do
        contract_json = read_file(file_path, file_name)
        items = Map.fetch!(contract_json, type)
        Enum.map(items, fn item ->
            EmbedbaseInteractor.insert_data(
                dataset_id, 
                item,  
                %{type: type, file_name: file_name, file_path: file_path}
            )
        end)
    end

    def upload(dataset_id, type, file_name) do
        contract_json = read_file(file_name, file_name)
        items = Map.fetch!(contract_json, type)
        Enum.each(items, fn item ->
            res = EmbedbaseInteractor.insert_data(
                dataset_id, 
                item,  
                %{type: type, file_name: file_name}
            )
            Logger.info("#{inspect(res)}")
        end)
    end
end