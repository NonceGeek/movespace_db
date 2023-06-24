defmodule ChatProgrammingWeb.CompanyAnalyzerLive do

    alias ChatProgramming.Accounts
    alias ChatProgramming.ExChatServiceInteractor
    use ChatProgrammingWeb, :live_view

    @impl true
    def mount(params, _session, socket) do
        current_user =
            Accounts.preload(socket.assigns.current_user)
        {
            :ok, 
            assign(
                socket,
                form: to_form(%{}, as: :f),
            )
        }

    end

    @impl true
    def handle_event("q-1", _params, socket) do
      {
        :noreply, 
        assign(socket,
            q_1: true
        )
      }
    end

    @impl true
    def handle_event("q-2", _params, socket) do
        IO.puts "q-2"
      {
        :noreply, 
        assign(socket,
            q_2: true
        )
      }
    end

    @impl true
    def handle_event("q-3", _params, socket) do
      {
        :noreply, 
        assign(socket,
            q_3: true
        )
      }
    end

    @impl true
    def handle_event("q-4", _params, socket) do
      {
        :noreply, 
        assign(socket,
            q_4: true
        )
      }
    end

    @impl true
    def handle_event("change-input", %{"_target" => ["f", "q_1_answer"], "f" => %{"q_1_answer" => q_1_answer_now}}, socket) do
      {
        :noreply, assign(socket,
            q_1_answer_now: q_1_answer_now
        )
      }
    end

    @impl true
    def handle_event("change-input", %{"_target" => ["f", "q_2_answer"], "f" => %{"q_2_answer" => q_2_answer_now}}, socket) do
      {
        :noreply, assign(socket,
            q_2_answer_now: q_2_answer_now
        )
      }
    end

    @impl true
    def handle_event("change-input", %{"_target" => ["f", "q_3_answer"], "f" => %{"q_3_answer" => q_3_answer_now}}, socket) do
      {
        :noreply, assign(socket,
            q_3_answer_now: q_3_answer_now
        )
      }
    end

    @impl true
    def handle_event("submit", %{"f" => f}, socket) do
        answer = 
            cond do
                !is_nil(f["q_1_answer"]) ->
                    question = "对于#{f["q_1_answer"]}类公司，当我们建立对这种公司的认知时，需要关注哪些特征？结果请使用 Markdown 格式输出。"
                    payload =  [%{role: "user", content: question}]
                    {:ok,
                        %{choices: choices}} = ExChatServiceInteractor.do_chat(:chatable, "gpt-3.5-turbo", payload)
                    handle_choices(:chatable, choices)
                true ->
                    nil
            end

        {
            :noreply, assign(socket,
                answer: answer
            )
        }
    end

    def handle_choices(:chatable, choices) do
        choices
        |> Enum.fetch!(0)
        |> Map.fetch!("message")
        |> Map.fetch!("content")
    end

    @impl true
    def handle_event(_key, _params, socket) do
      {
        :noreply, socket
      }
    end

    @impl true
    def render(assigns) do
      ~H"""
        <br>
        <.container class="mt-10">
            <center>
                <.h1>Company Smart Analyzer</.h1>
                <.h5>数据集情况: </.h5>
                <.badge color="primary" label="博报堂希点" />
                <.badge color="secondary" label="JNC膝跳" />
                <.badge color="info" label="AUTOMOTIVE" />
                <.badge color="success" label="沃德达彼斯" />
                <.badge color="warning" label="北京威信" />
                <.badge color="danger" label="君为仁和" />
                <.badge color="gray" label="艾德韦宣" />
                <br><br>
                <hr>
                <br>
                <.form for={@form} phx-change="change-input" phx-submit="submit">
                    <!--<br>
                    <.textarea form={@form} field={:question} value={assigns[:question_now]}/>-->
                    <br>
                    <.p> 一般性回答: </.p>
                    <br>
                    <.button phx-click="q-1" color="white" variant="shadow">
                        对于 __ 类公司，当我们建立对这种公司的认知时，需要关注哪些特征？
                    </.button>
                    <br><br>
                    <%= if assigns[:q_1] do %>
                        对于 
                        <.text_input 
                        form={@form} 
                        field={:q_1_answer} 
                        value={assigns[:q_1_answer_now]}
                        placeholder="广告" 
                        style="width:100px"/> 
                        类公司，当我们建立对这种公司的认知时，需要关注哪些特征?
                    <% end %>
                    <br><br>
                    
                    <br><br>
                    <hr>
                    <br>
                    <.p> 基于向量数据库获取回答: </.p>
                    <br>
                    <.button phx-click="q-2" color="white" variant="shadow">
                        简述 __ 公司具备哪些特征？
                    </.button>
                    <.button phx-click="q-3" color="white" variant="shadow">
                        生成关于 __ 公司的简介。
                    </.button>
                    <.button phx-click="q-4" color="white" variant="shadow">
                        分析 __ 这些公司有哪些共性？
                    </.button>
                    <br><br>

                    <%= if assigns[:q_2] do %>
                        简述 
                        <.text_input 
                        form={@form} 
                        field={:q_2_answer} 
                        value={assigns[:q_2_answer_now]}
                        placeholder="北京威信" 
                        style="width:100px"/> 
                        公司具备哪些特征？
                    <% end %>

                    <%= if assigns[:q_3] do %>
                        生成关于 
                        <.text_input 
                        form={@form} 
                        field={:q_3_answer} 
                        value={assigns[:q_3_answer_now]}
                        placeholder="北京威信" 
                        style="width:100px"/> 
                        公司的简介。
                    <% end %>

                    <%= if assigns[:q_4] do %>
                        分析 
                        <.text_input 
                        form={@form} 
                        field={:q_4_answer} 
                        value={assigns[:q_4_answer_now]}
                        placeholder="博报堂希点、JNC膝跳、AUTOMOTIVE、沃德达彼斯、北京威信、君为仁和、艾德韦宣" 
                        style="width:800px"/> 
                        这些公司的共性。
                    <% end %>
                    
                    <br><br>
                    <.button phx-click="ask-question">生成结果</.button>
                    <br><br>
                    <%= if assigns[:answer] do %>
                        <%= raw(Earmark.as_html!(assigns[:answer])) %>
                    <% end %>
                </.form>

            </center>
        </.container>

      """
    end
end