defmodule ChatProgrammingWeb.ChatNewLive do
  use ChatProgrammingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    IO.puts inspect socket.assigns.flash
    {:ok, socket}
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

    @impl true
  def render(assigns) do
    ~H"""
        <center>
        <p><%= live_flash(@flash, :info) %></p>
        <p>--- 🚧施工中🚧 ---</p>
        <p>--- 基于基础的 Prompt，输入 JSON 问题树🌲，生成答案树🌲 ---</p>
         <p>--- 并可以进行结果的导出 ---</p>
        </center>
    """
  end

end