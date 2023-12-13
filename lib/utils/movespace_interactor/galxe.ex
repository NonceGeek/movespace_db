defmodule MovespaceInteractor.Galxe do
    @moduledoc """
        interact with: https://gist.github.com/leeduckgo/2ce1511a4b284fe819ff807a1701da38
    """

    require Logger

    @doc """
        如果給了一個限制的數量，那麼只有那個數目的資料列會回傳（如果查詢本身產生較少的資料列，則可能會少一些）。LIMIT ALL 與省略 LIMIT 子句相同，也如同 LIMIT 的參數為 NULL。
        OFFSET 指的是在開始回傳資料列之前跳過那麼多少資料列。OFFSET 0 與忽略 OFFSET 子句相同，就像使用 NULL 參數的 OFFSET 一樣。
        如果同時出現 OFFSET 和 LIMIT，則在開始計算回傳的LIMIT 資料列之前，先跳過 OFFSET 數量的資料列。
        —— https://docs.postgresql.tw/the-sql-language/queries/limit-and-offset
    """
    def query_campaign_list(endpoint, alias_name, limit \\ 50, offset \\ -1) do
        body =  %{
            params: [alias_name, limit, offset]
        }

        ExHttp.http_post(
            "#{endpoint}/api/v1/run?name=GalxeInteractor&func_name=query_campaign_list", 
            body
        )
    end
end