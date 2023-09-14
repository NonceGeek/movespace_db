defmodule ChatProgrammingWeb.PageLive do
  alias ChatProgramming.{Space, Card}
  alias ChatProgramming.SmartPrompterInteractor
  alias ChatProgramming.TemplateHandler
  use ChatProgrammingWeb, :live_view


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

    {:ok,
     assign(
       socket,
       # forms.
       form: to_form(%{}, as: :f),
       form_filter: to_form(%{}, as: :f), 
       form_prompt_generator: to_form(%{}, as: :f), 
       # prompt service login info.
       smart_prompter_user: smart_prompter_user,
       # templates.
       prompt_templates: prompt_templates
     )}
  end

  def handle_event("submit", %{"f" => %{"select_dataset" => dataset_selected, "dataset_name" => dataset_name, "question" => q}}, socket) do
    embedbase_id = select_dataset(dataset_selected, dataset_name)
    if String.contains?(q, "in metadata should be")== true do
      # filter the item by metadata.
      # get the key are value
      # filter the result
      # TODO: optimize.
      res = String.split(q, "\"")
      key = res |> Enum.fetch!(-4)
      value = res |> Enum.fetch!(-2)
      # search the dataset about the question.
      {:ok, %{similarities: similarities}} = 
        EmbedbaseInteractor.search_data(embedbase_id, q)
      search_result_filtered = filter_search_result(similarities, key, value)
      {
        :noreply, 
        assign(socket,
          search_result: search_result_filtered
        )
      }
    else
      # not filter.
      search(embedbase_id, q, socket)
    end

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
  
  def handle_event("submit_for_generate_prompt", %{"f" => %{"question" => q}}, socket) do
    IO.puts inspect socket.assigns.template_selected.id
    # TODO: update it.
    prompt_final = 
    case socket.assigns.template_selected.id do
      10 ->
        template_selected = socket.assigns.template_selected

        search_result = socket.assigns.search_result
        build_codes = build_code(search_result)
        type = search_result |> Enum.fetch!(0) |> Map.fetch!(:metadata) |> Map.fetch!(:type)
        TemplateHandler.gen_prompt(template_selected.content, %{type: type, codes: build_codes, question: q})
      11 ->
        template_selected = socket.assigns.template_selected
        search_result = socket.assigns.search_result
        content = build_code(search_result)
        TemplateHandler.gen_prompt(template_selected.content, %{content: content, question: q})

      end
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
            MoveSpaceDB: Prompt-to-Query Dashboard, powered by OpenAI.
          </span>
        </.h2>
      </center>
    </.container> 
    <!-- Vector Dataset Interactor-->

    <.container class="mt-10">  
      <center>
        <.simple_form for={@form} phx-change="change_input" phx-submit="submit">

          <.p>
            Submit a proposal to the public vector datasets by 
            <a href="https://vector-dataset-governancer.vercel.app/" target="_blank" style="color:blue">Governancer dApp</a>, 
            Or see the proposals in
            <a href="/proposal_viewer" target="_blank" style="color:blue">Proposal Panel</a>.
          </.p>

          <.p>Select the Vector Dataset:</.p>
          <.select options={["aptos-smart-contracts-fragment-by-structure": "aptos-smart-contracts-fragment-by-structure", "aptos-whitepaper-handled": "aptos-whitepaper-handled"]} form={@form} field={:select_dataset} value={assigns[:selected_vd_now]}/>
          <.p>Or Input the <a href="https://app.embedbase.xyz/datasets" target="_blank" style="color:blue">Public Dataset</a> Name:</.p>
          <.text_input form={@form} field={:dataset_name} placeholder="eg. web3-dataset" />

          <!-- result panel -->
          <div class="grid gap-5 mt-5 md:grid-cols-1 lg:grid-cols-1" style="height: auto;">
            <.card>
                <%= if not is_nil(assigns[:search_result]) do %>
                  <br>
                  <.p><b>Search Results in Dataset:</b></.p>
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
            <.p>A search question example: Give me the examples about struct. The "type" in metadata should be "struct".</.p>

            <.button color="secondary" label="Search!" variant="outline" />
          </.simple_form>

          <%= if not is_nil(assigns[:search_result]) do %>

          <center>
            <.simple_form for={@form_prompt_generator} phx-change="prompter_generator_change" phx-submit="submit_for_generate_prompt">
            <.p><b>Generate Prompt for LLM by the Question:</b></.p>
            <.text_input form={@form_prompt_generator} field={:question} value={assigns[:prompt_question_now]} placeholder="question" />
            <.p>A llm question example: Please Generate a struct which named AddressAggregator.</.p>
            <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-4">
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

      </center>

      
    </.container> 
    <br>
    <hr>


    <!-- Guides -->
    <!--
    <.container class="mt-10">  
      <center>
        <.h3>- How could I create the Dataset? -</.h3>
      </center>
    </.container>

    <.container class="mt-10">
      <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-4">
        <.card>
          <center>
            <.card_content heading="PDF -> Datasets">
              <a style="color:blue" href="https://docs.embedbase.xyz/snippets#add-pdfs-or-docx-files-to-your-dataset-in-python" target="_blank">
                API way
              </a>
            </.card_content>
          </center>
        </.card>

        <.card>
          <center>
            <.card_content heading="Markdown -> Datasets">
              <a style="color:blue" href="https://docs.embedbase.xyz/tutorials/nextra-qa-docs" target="_blank">
                Guide
              </a>
            </.card_content>
          </center>
        </.card>
      </div>
    </.container>
    <br>
    <hr>
    -->
    <!-- Good Projects -->
 
    <.container class="mt-5">
      <center>
        <.h3> Project Hodler </.h3>
      </center>
      <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-2">
        <.card>
          <br>
          <center>
            <a href="https://noncegeek.com/" target="_blank">
              <.card_media src={~p"/images/logo_ng.png"} style="width: 50%"/>
            </a>
          </center>
        </.card>

      
      <.card>
        <br>
        <center>
          <.card_media src={~p"/images/logo_2718.png"} style="width: 50%"/>
        </center>
      </.card>
    </div>
    </.container>
    <br><hr>
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
