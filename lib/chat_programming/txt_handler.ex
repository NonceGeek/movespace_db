defmodule ChatProgramming.TxtHandler do

    @default_folder "files"
    def delete_useless_spaces(str) do
        str
        |> String.replace("\r", "") 
        |> String.replace("\n", "") 
        |> String.replace("\f", "")
        |> String.replace(" ","")
    end

    def tag_txt(name, txt) do
        "## #{name} \n #{txt} \n"
    end

    def combine_files(output_name, :md) do
        context = read_file(:md)
        File.write!("#{@default_folder}/#{output_name}.md", context)
    end

    # using file_name as tag_name
    def read_files(:list) do
        do_read_files()
    end
    def read_files(:md) do
        do_read_files()
        |> Enum.reduce("", fn section, acc -> acc <> section end)
    end

    def do_read_files() do
        files = get_all_txt_files(@default_folder)
        files
        |> Enum.map(fn file_name ->
            read_file(file_name)
        end)
        |> List.flatten()
    end

    def read_file(file_name) do
        txt = 
        "#{@default_folder}/#{file_name}"
        |> File.read!()
        |> delete_useless_spaces()
        name = String.replace(file_name, ".txt", "")
        if String.length(txt) >= 8000 do
            # TODO: split logic.
            {head, tail} = String.split_at(txt, 8000)
            [
                %{
                    tag: "#{name}_0x01",
                    content: tag_txt("#{name}_0x01", head)
                }, 
                %{
                    tag: "#{name}_0x02", 
                    content: tag_txt("#{name}_0x02", tail)
                }
            ]
        else
            %{
                tag: "#{name}",
                content: tag_txt(name, txt)
            }
        end
    end

    def get_all_txt_files(path) do
        path
        |> File.ls!()
        |> Enum.filter(fn name -> String.contains?(name, ".txt") end)
    end
end