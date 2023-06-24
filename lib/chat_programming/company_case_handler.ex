defmodule ChatProgramming.CompanyCaseHandler do
    @moduledoc """
        The Way: 
        old dataset
            ↓
        each vector is a company info.
            ↓
        slice the company information by token num.
            ↓
        summary the 5 topic main topic of each slice.
            ↓
        get the section based of the topic.
            ↓
        add the slice to a new dataset
            ↓
        get the new dataset!
    """

    alias ChatProgramming.TxtHandler

    def init_dataset_ori() do
        data_set = TxtHandler.read_files(:list)
        EmbedbaseInteractor.insert_data("ad-company-case-ori", data_set)
    end

    def get_main_topic() do
        data_set = TxtHandler.read_files(:list)
    end
end