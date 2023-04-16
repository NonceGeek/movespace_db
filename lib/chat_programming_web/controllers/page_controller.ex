defmodule ChatProgrammingWeb.PageController do
  use ChatProgrammingWeb, :controller

  def home(conn, _params) do
    render(conn, :home, active_tab: :home)
  end
end
