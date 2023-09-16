defmodule ChatProgramming.CLI do
    alias ChatProgramming.MarkdownParser
    require Logger
    def main(args) do
        {opts, _others, _others_2} =
        OptionParser.parse(args,
            strict: [path: :string, embedbaseid: :string, insert: :boolean, delete: :boolean],
            aliases: [f: :filepath, e: :embedbaseid, i: :insert, d: :delete])
        opts
        |> Enum.into(%{})
        |> handle_args()
    end

    # insert.
    # path for example: "data_resources/aptos/aptos_white_paper_handled.md"
    def handle_args(%{insert: true, embedbaseid: embedbase_id, path: path}) do
        # parse the .md File
        # insert into embedbase
        # insert_data(dataset_id, data, metadata)
        path
        |> MarkdownParser.read()
        |> Enum.map(fn %{content: content, keywords: keywords} ->
            # TODO: optimize:
            metadata = 
                %{
                    keywords_0: Enum.fetch!(keywords, 0), 
                    keywords_1: Enum.fetch!(keywords, 1), 
                    keywords_2: Enum.fetch!(keywords, 2), 
                    keywords_3: Enum.fetch!(keywords, 3), 
                    keywords_4: Enum.fetch!(keywords, 4), 
                }
            # TODO: need a log here.
            Logger.info("---count insert---")
            EmbedbaseInteractor.insert_data(embedbase_id, content, metadata)
        end)
        
    end
end