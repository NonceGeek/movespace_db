defmodule ChatProgrammingWeb.AutonomousBookLive do
  alias ChatProgramming.{Space, Card}
  alias ChatProgramming.SmartPrompterInteractor
  alias ChatProgramming.TemplateHandler
  use ChatProgrammingWeb, :live_view

  # mocked
  def book_content() do
    """
## 0x01 Introduction to Elixir

1. "What is Elixir, and what are the features of Elixir? Plz give me some important link."
2. "Who is suitable for software development with Elixir?"

3. "Plz introduce about the Phoniex Web Framework in Elixir and give me some important link."
4. "Plz introduce about the Liveview in Elixir and give me some important link."
5. "Plz introduce about the Livebook in Elixir and give me some important link."
    """
    |> Earmark.as_html!()
    # Optimize: adapt to the tailwind.
  end
  # @default_endpoint "http://localhost:4001"
  @default_endpoint Constants.smart_prompter_endpoint()
  @impl true
  def mount(params, _session, socket) do
    {smart_prompter_user, prompt_templates} = 
    if Constants.service_smart_prompter?() do
      :ok = SmartPrompterInteractor.set_session(@default_endpoint)
      smart_prompter_user = %{id: id}= SmartPrompterInteractor.get_current_user(@default_endpoint)
      {:ok, %{data: prompt_templates}} = SmartPrompterInteractor.list_template(@default_endpoint, id)
      {smart_prompter_user, prompt_templates}
    else
      {nil, []}
    end
    prompt_templates = prompt_templates |> Enum.filter(fn template -> template.id == 13 end)
    {:ok,
     assign(
       socket,
       # forms.
       book_content: book_content(),
       form: to_form(%{}, as: :f),
       form_filter: to_form(%{}, as: :f), 
       form_prompt_generator: to_form(%{}, as: :f), 
       # prompt service login info.
       smart_prompter_user: smart_prompter_user,
       # templates.
       prompt_templates: prompt_templates
     )}
  end


  def handle_event("submit", %{"f" => %{"select_dataset" => dataset_selected, "question" => q}}, socket) do 
    # not filter.
    search(dataset_selected, q, socket)
  end

  def search(embedbase_id, question, socket) do
    # search the dataset about the question.
    {:ok, %{similarities: similarities}} = 
      EmbedbaseInteractor.search_data(embedbase_id, question)
    
    {
      :noreply, 
      assign(socket,
        search_result: similarities
      )
    }
  end

  def select_dataset(dataset_selected, ""), do: dataset_selected
  def select_dataset(_, dataset_name), do: dataset_name

  def filter_search_result(search_result, key, value) do
    Enum.filter(search_result, fn %{metadata: metadata} ->
      # IO.puts inspect Map.fetch(metadata, String.to_atom(key))
      Map.fetch(metadata, String.to_atom(key)) == {:ok, value}
    end)
  end

  def handle_event("change_input", %{"_target" => ["f", "question"], "f" => %{"question" => question}}, socket) do
    {
      :noreply, 
      assign(socket,
        search_question_now: question
      )
    }
  end

  def handle_event("change_input", %{"_target" => ["f", "select_dataset"],  "f" => %{"select_dataset" => selected_vd}} = params, socket) do
    {
      :noreply, 
      assign(socket,
        selected_vd_now: selected_vd
      )
    }
  end

  def handle_event("prompter_generator_change", %{"_target" => ["f", "question"], "f" => %{"question" => question}}, socket) do
    {
      :noreply, 
      assign(socket,
        prompt_question_now: question
      )
    }
  end
  
  def handle_event("submit_for_generate_prompt", %{}, socket) do
    question = socket.assigns.search_question_now
    template_selected = socket.assigns.template_selected
    search_result = socket.assigns.search_result
    content = build_code(search_result)
    prompt_final = TemplateHandler.gen_prompt(template_selected.content, %{content: content, question: question})
    {
      :noreply, assign(socket,
        prompt_final: prompt_final
      )
    }
  end

  def handle_event("redirect_to_chat", _, socket) do
    {
      :noreply, 
      socket
      |> put_flash(:info, socket.assigns.prompt_final)
      |> redirect(to: "/chat_new")
      }
  end

  def handle_event("generate_prompt", %{"template-id" => template_id_str}, socket) do

    templates = socket.assigns.prompt_templates

    template_selected = Enum.find(templates, fn template -> template.id == String.to_integer(template_id_str) end)

    {
      :noreply, assign(socket,
        template_selected: template_selected,
      )
    }
  end

  def build_code(search_result_filtered) do
    Enum.reduce(search_result_filtered, "", fn elem, acc ->
      acc <> "* " <> elem.data <> "\n"
    end)
  end

  def handle_event(others, params, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <.container class="mt-10">

      <center>
        <.h2>
          <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500">
            Autonomous B00K
          </span>
        </.h2>
      </center>
    </.container> 

    <.container class="mt-10">  
        <.simple_form for={@form} phx-change="change_input" phx-submit="submit">
            <center>
            <.p>
            GPT-based & VectorDB-based self-evolving book paradigm.
            </.p><.p>
            See an example on Github:
            <a href="https://github.com/NonceGeek/autonomous-elixir-book" target="_blank" style="color:blue">Autonomous Elixir B00k</a>.
            </.p>

          <.p>Select the VectorDB:</.p>
          <.select options={[
            "autonomous elixir book": "autonomous-elixir-book", 
            ]} form={@form} field={:select_dataset} />
            </center>
            <%= raw(@book_content)%>

          <div class="grid gap-5 mt-5 md:grid-cols-1 lg:grid-cols-1" style="height: auto;">
            <.card>
                <%= if not is_nil(assigns[:search_result]) do %>
                  <br>
                  <.p><b>Search Results in vectorDB:</b></.p>
                  <.table>
                    <thead>
                      <.tr>
                        <.th>Result</.th>
                        <.th>Metadata</.th>
                      </.tr>
                    </thead>
                    <tbody>
                    <%= for elem <- assigns[:search_result] do %>
                      <.tr>
                        <.td><%= elem.data %></.td>
                        <.td><%= inspect(elem.metadata) %></.td>
                      </.tr>
                    <% end %>
                    </tbody>
                  </.table>

                <% else %>
                  <br><br><br>
                    <b>the search results would be shown here.</b>
                  <br><br><br><br>
                <% end %>
              </.card>
            </div>

            <.text_input form={@form} field={:question} placeholder="Enter your prompt to search" value={assigns[:search_question_now]}/>

            <.button color="secondary" label="Search!" variant="outline" />

          </.simple_form>
            <br>
            <.button color="primary" label="I wanna submit my knowledge to the vectorDB!" variant="outline" />


          <%= if not is_nil(assigns[:search_result]) do %>

          <center>
            <.simple_form for={@form_prompt_generator} phx-change="prompter_generator_change" phx-submit="submit_for_generate_prompt">
            <.p><b>Generate Prompt for LLM by the Question:</b></.p>
            <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-3">
              <%= for template <- @prompt_templates do %>
                <.card>
                  <center>
                    <.card_content heading={template.title}>
                      <%= raw(Earmark.as_html!(template.content)) %>
                      <br><br>
                      <.button color="secondary" phx-value-template-id={template.id} phx-click="generate_prompt" label="Generate Prompt!" variant="outline" />
                    </.card_content>
                  </center>
                </.card>
              <% end %>
              </div>
            </.simple_form>
          </center> 
          <br><br>


            <%= if not is_nil(assigns[:prompt_final]) do %>
                <div class="grid gap-5 mt-5 md:grid-cols-1 lg:grid-cols-1" style="height: auto;text-align: left">
                  <.card>
                    <.card_content>
                      <br>
                        <%= raw(Earmark.as_html!(assigns[:prompt_final]))%>
                      <br>
                    </.card_content>
                  </.card>
                </div>

                  <center>
                  <br><br>
                  <a href="https://chat.openai.com/" target="_blank">
                    <.button color="secondary" label="Ask ChatGPT!" variant="outline" />
                  </a>
                  <br><br>
                  OR
                  <br><br>
                  <.button color="secondary" phx-click="redirect_to_chat" label="Ask Smart Prompter" variant="outline" />
                  </center>

            <% end %>


          <% end %>
    </.container> 
    <br>
    <hr>
   
    <center>
      <br>
      <.p>
        𑖌𑖼2023 NonceGeekDAO & 2718.AI & 苏州喵自在区块链科技有限公司.𑖌𑖼
        <br>
        ALL RIGHTS RESERVED.
        <br>
      </.p>
    </center>
    """
  end
end
