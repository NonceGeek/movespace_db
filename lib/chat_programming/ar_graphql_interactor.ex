defmodule ChatProgramming.ArGraphQLInteractor do
    @url "https://arweave.net/graphql"


  def query_by_tags(tags, url \\ @url) do
    body = build_body(tags)
    request = %HTTPoison.Request{
      method: :post,
      url: url,
      headers: [
        {~s|Accept-Encoding|, ~s|gzip, deflate, br|},
        {~s|Content-Type|, ~s|application/json|},
        {~s|Accept|, ~s|application/json|},
        {~s|Connection|, ~s|keep-alive|},
        {~s|DNT|, ~s|1|},
        {~s|Origin|, ~s|https://arweave.net|},
      ],
      body: body
    }
    try do
      {:ok, %{body: body, status_code: 200}} = HTTPoison.request(request)
      {:ok, body |> Poison.decode!() |> ExStructTranslator.to_atom_struct()}
    rescue
      error ->
      {:error, inspect(error)}
    end
  end

  def query_by_raw(raw, url \\ @url) do
    body = build_body(:raw, raw)
    request = %HTTPoison.Request{
      method: :post,
      url: url,
      headers: [
        {~s|Accept-Encoding|, ~s|gzip, deflate, br|},
        {~s|Content-Type|, ~s|application/json|},
        {~s|Accept|, ~s|application/json|},
        {~s|Connection|, ~s|keep-alive|},
        {~s|DNT|, ~s|1|},
        {~s|Origin|, ~s|https://arweave.net|},
      ],
      body: body
    }
    try do
      {:ok, %{body: body, status_code: 200}} = HTTPoison.request(request)
      {:ok, body |> Poison.decode!() |> ExStructTranslator.to_atom_struct()}
    rescue
      error ->
      {:error, inspect(error)}
    end
  end

  def build_body(tags) do
    tags_str = 
        tags
        |> Enum.reduce("[", fn {key, value}, acc -> acc <> "{name: \"#{key}\", values: \"#{value}\"}" end)
        |> Kernel.<>("]")
    Poison.encode!(%{query:
      "query {transactions(tags: #{tags_str}) {edges {node {id}}}}"})
  end

  def build_body(:raw, raw) do
    Poison.encode!(%{query: raw})
  end
end