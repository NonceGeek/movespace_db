defmodule ChatProgrammingWeb.ChatterLive do
    alias ChatProgramming.{Space, Card}
    alias ChatProgramming.ExChatServiceInteractor
    alias ChatProgramming.{SmartPrompterInteractor, PromptHandler}
    alias ChatProgramming.Accounts
    use ChatProgrammingWeb, :live_view

    @smart_prompter_endpoint "http://localhost:4001"
    require Logger

    @impl true
    def mount(params, _session, socket) do
      current_user =
        Accounts.preload(socket.assigns.current_user)
      if Constants.service_smart_prompter?() == true do
        SmartPrompterInteractor.set_session(@smart_prompter_endpoint)
        {:ok, %{data: prompt_templates}} = SmartPrompterInteractor.list_template(@smart_prompter_endpoint)
        {:ok,
        assign(
          socket,
          current_user: current_user,
          prompt_templates: prompt_templates,
          form: to_form(%{}, as: :f),
        )}
      else
        {:ok,
        assign(
          socket,
          current_user: current_user,
          form: to_form(%{}, as: :f),
        )}
      end

    end

    @impl true
    def handle_params(%{"model_name" => model_name, "topic" => topic}, _uri, socket) do
      {
        :noreply,
        assign(socket,
        topic: topic,
        model_name: model_name
        )
    }
    end

    @impl true
    def handle_params(_, _uri, socket) do
      {
        :noreply,
        assign(socket,
        topic: "programming",
        model_name: "davinci"
        )
      }
    end

    def human_text_to_payload(human_textarea) do
      "Human: #{human_textarea} AI: "
    end

    def handle_choices(choices) do
      first_answer =
        choices
        |> Enum.fetch!(0)
        |> Map.fetch!("text")
      first_answer |> String.split("Human:") |> Enum.fetch!(0)
    end

    def handle_choices(:chatable, choices) do
        choices
        |> Enum.fetch!(0)
        |> Map.fetch!("message")
        |> Map.fetch!("content")
    end

    @impl true
    def handle_event("change-input", %{"_target" => ["f", "human_textarea"], "f" => %{"human_textarea" => textarea_now}}, socket) do
      {
        :noreply,
        assign(socket,
          textarea_now: textarea_now
        )
      }
    end

    @impl true
    def handle_event("change-input", %{"_target" => ["f", "system"], "f" => %{"system" => system_now, "user" => user_now}}, socket) do
      {
        :noreply,
        assign(socket,
          system_now: system_now,
          user_now: user_now
        )
      }
    end

    @impl true
    def handle_event("change-input", %{"_target" => ["f", "user"], "f" => %{"system" => system_now, "user" => user_now}}, socket) do
      {
        :noreply,
        assign(socket,
          system_now: system_now,
          user_now: user_now
        )
      }
    end

    @impl true
    def handle_event("change-input", %{"_target" => ["f", field], "f" => f}, socket) do
      payload = Map.get(f, field)
      prompt_vars =
        Map.put(socket.assigns[:prompt_vars], field, payload)
        {
          :noreply,
          assign(socket,
            prompt_vars: prompt_vars
          )
        }
    end

    @impl true
    def handle_event("change-input", _params, socket) do
        {
          :noreply,
          socket,
        }
    end

    @impl true
    def handle_event("submit", %{"f" => %{"system" => system_content, "user" => user_content}}, socket) do
      do_handle_event(socket.assigns.model_name, system_content, user_content, socket)
      {
        :noreply,
        socket
      }
    end

    @impl true
    def handle_event("submit", %{"f" => %{"human_textarea" => human_textarea}}, socket) do
      do_handle_event(socket.assigns.model_name, human_textarea, socket)
    end

    @impl true
    def handle_event("recognize-prompt", %{"prompt" => prompt}, socket) do
      vars = PromptHandler.recog_vars(prompt)
      {
        :noreply,
        assign(socket,
          vars_in_prompt: vars,
          prompt_vars: %{}
        )
      }
    end


    @impl true
    def handle_event("renew-prompt", _params, socket) do
      vars = socket.assigns[:prompt_vars]
      prompt_new = PromptHandler.impl_vars(socket.assigns.system_now, vars)
      IO.puts prompt_new
      {
        :noreply,
        assign(socket,
          system_now: prompt_new
        )
      }
    end

    @impl true
    def handle_event("get-answer", _params, socket) do
      Logger.info("model_name: #{socket.assigns.model_name}")
      Logger.info("system_now: #{socket.assigns.system_now}")
      Logger.info("user_now: #{socket.assigns.user_now}")

      do_handle_event(socket.assigns.model_name, socket.assigns.system_now, socket.assigns.user_now, socket)
    end



    @doc """
      #TODO: recognize model smartly to adapt model.
      gpt-4, gpt-4-0314, gpt-4-32k, gpt-4-32k-0314, gpt-3.5-turbo, gpt-3.5-turbo-0301

      > https://platform.openai.com/docs/models/model-endpoint-compatibility
    """
    def do_handle_event(model_name, system_content, user_content, socket)
      when model_name in ["gpt-4", "gpt-4-0314", "gpt-4-32k", "gpt-4-32k-0314", "gpt-3.5-turbo", "gpt-3.5-turbo-0301"] do

        payload =  build_content(system_content, user_content)
        {:ok,
          %{choices: choices}} = ExChatServiceInteractor.do_chat(:chatable, model_name, payload)
        result = handle_choices(:chatable, choices)
        {
          :noreply,
          assign(socket,
            result: result
          )
        }
    end

    def build_content(system_content, user_content) do
      [
        %{role: "system", content: system_content},
        %{role: "user", content: user_content}
      ]
    end

    def do_handle_event(model_name, human_textarea, socket) do
      # payload = human_text_to_payload(human_textarea)
      {:ok, %{choices: choices}} =

      ExChatServiceInteractor.do_chat(model_name, human_textarea)

      result = handle_choices(choices)
      {
        :noreply,
        assign(socket,
          result: result
        )
      }
    end

    @impl true
    def render(assigns) do
      ~H"""
        <.container class="mt-10">
          <.h1>
            <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
              Chat <%= @topic %>
            </span>
          </.h1>
          <.h5>Chat to learning anything about  <%= @topic %>.</.h5>

        <.form for={@form} phx-change="change-input" phx-submit="submit">
          <%= if @model_name in ["gpt-4", "gpt-4-0314", "gpt-4-32k", "gpt-4-32k-0314", "gpt-3.5-turbo", "gpt-3.5-turbo-0301"] do %>
            <%= if not is_nil(assigns[:prompt_templates]) do %>
              <.p>Prompt Templates: </.p>
                <.table>
                  <thead>
                    <.tr>
                      <.th>Name</.th>
                      <.th>Prompt</.th>
                    </.tr>
                  </thead>
                  <tbody>
                  <%= for template <- assigns[:prompt_templates] do %>
                    <.tr>
                      <.td><%= template.title %></.td>
                      <.td><%= template.content %></.td>
                    </.tr>
                  <% end %>
                  </tbody>
                </.table>
            <% end %>

            <br>
            <.p>Implement the Content: </.p>
            <br>
            <.p>Prompt Template</.p>
            <br>
            <.textarea form={@form} field={:system} value={assigns[:system_now]}/>
            <br>
            <.button phx-click="recognize-prompt" phx-value-prompt={assigns[:system_now]} >Smart Recognize</.button>
            <br><br>
            <%= if not is_nil(assigns[:vars_in_prompt]) do %>
              <%= for var <- assigns[:vars_in_prompt] do %>
                <.input field={@form[String.to_atom(var)]} label={"#{var}"}/>
              <% end %>
            <% end %>
            <%= inspect(assigns[:prompt_vars]) %>
            <br><br>
            <.button phx-click="renew-prompt">Renew Prompt</.button>
            <br><br>
            <.p>User say something: </.p>
            <br>
            <.textarea form={@form} field={:user} value={assigns[:user_now]}/>
            <br><br>
            <.button phx-click="get-answer" color="pure_white" label="Get Answer ⏎" />
            <%= if not is_nil(assigns[:result]) do %>
              <.p> <%= inspect(assigns[:result]) %></.p>
            <% end %>
          <% else %>
            <.p>Human Say Something: </.p>
            <.textarea form={@form} field={:human_textarea} value={assigns[:textarea_now]}/>
            <br><br>
            <.button phx-click="get-answer" color="pure_white" label="Get Answer ⏎" />
            <%= if not is_nil(assigns[:result]) do %>
              <.p> <%= inspect(assigns[:result]) %></.p>
            <% end %>
          <% end %>
        </.form>
        </.container>
      """
    end
  end
