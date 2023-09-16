defmodule ChatProgramming.MarkdownParser do
    @moduledoc """
        parse markdown for insert Vector Dataset.
    """

    @doc """
        read and parse the md file with anno.
    """
    def read(path_and_name) do
        file =  File.read!(path_and_name)
        comments = 
            file
            |> Earmark.as_ast!() # to ast
            |> Enum.filter(fn elem -> elem |> Tuple.to_list |> Enum.fetch(0) == {:ok, :comment} end) # get all the comment.
            # |> Enum.chunk_by(fn elem -> elem |> Tuple.to_list |> Enum.fetch(0) == {:ok, :comment} end) # split by the comment.
            # |> Enum.chunk_every(2) # chunk content and comment.
            |> Enum.map(fn {:comment, [], [comment], %{comment: true}} 
                -> comment 
            end) # handle comment
        file
        |> handle_md_by_the_comments([], comments)
        |> Enum.map(fn %{keywords: keywords_raw} = elem ->
            keywords_handled = 
                keywords_raw
                |> String.split("\\n")
                |> Enum.map(fn keyword -> String.trim(keyword, "1.") end)
                |> Enum.map(fn keyword -> String.trim(keyword, "2.") end)
                |> Enum.map(fn keyword -> String.trim(keyword, "3.") end)
                |> Enum.map(fn keyword -> String.trim(keyword, "4.") end)
                |> Enum.map(fn keyword -> String.trim(keyword, "5.") end)
                |> Enum.map(fn keyword -> String.trim(keyword) end) # trim spaces.
            Map.put(elem, :keywords, keywords_handled)
        end)
    end

    def handle_md_by_the_comments(file, acc, comments) do
        if comments == [] do
            acc
        else 
            {comment, rem} = List.pop_at(comments, 0)
            [bef, aft] = String.split(file, "<!--#{comment}-->")
            handle_md_by_the_comments(
                aft, # file = aft
                acc ++ [%{content: "#{bef}\n\nkeywords: #{comment}", keywords: comment}], # acc + new
                rem # comments =-1
            )
        end
    end

end