defmodule ChatProgrammingWeb.ProposalController do
  use ChatProgrammingWeb, :controller
  alias ChatProgramming.Proposal

  @resp_success %{
    error_code: 0,
    error_msg: "success",
    result: ""
  }

  @resp_failure %{
    error_code: 1,
    error_msg: "",
    result: ""
  }

  def create(conn, params) do
    case Proposal.create(params) do
      {:ok, _proposal} ->
        json(conn, get_res("create proposal success", :ok))
      {:error, changeset} ->
        json(conn, get_res(inspect(changeset), :error))
    end
  end

  def get_res(payload, :ok) do
    Map.put(@resp_success, :result, payload)
  end

  def get_res(payload, :error) do
    Map.put(@resp_failure, :error_msg, payload)
  end
end
