defmodule ChatProgramming.MixedChat do
    alias  ChatProgramming.ExChatServiceInteractor
    def chat(dataset_id, question) do
        {:ok,
            %{
                similarities: vector
            }
        } = EmbedbaseInteractor.search_data(dataset_id, question)
        first_vector = Enum.fetch!(vector, 0)
        msgs = build_msgs(first_vector.data, question)
        ExChatServiceInteractor.do_chat(:chatable, "gpt-3.5-turbo", msgs)
    end

    def build_msgs(information, question) do
        [
            %{role: "system", content: information},
            %{role: "user", content: question}
        ]
        # [
        #     %{role: "system", content: "You are a helpful assistant."},
        #     %{role: "user", content: "Who won the world series in 2020?"},
        #     %{role: "assistant", content: "The Los Angeles Dodgers won the World Series in 2020."},
        #     %{role: "user", content: "Where was it played?"}
        # ]
    end

    
end