defmodule ChatProgrammingWeb.PageLive do
  alias ChatProgramming.{Space, Card}
  alias ChatProgramming.SmartPrompterInteractor
  alias ChatProgramming.TemplateHandler
  use ChatProgrammingWeb, :live_view

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
    search(embedbase_id, q, socket)
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

  def handle_event("submit_for_filter", %{"f" => %{"key" => key, "value" => value}}, socket) do
    search_result_filtered = filter_search_result(socket.assigns.search_result, key, value)
    {
      :noreply, 
      assign(socket,
        search_result_filtered: search_result_filtered
      )
    }
  end

  def filter_search_result(search_result, key, value) do
    Enum.filter(search_result, fn %{metadata: metadata} ->
      # IO.puts inspect Map.fetch(metadata, String.to_atom(key))
      Map.fetch(metadata, String.to_atom(key)) == {:ok, value}
    end)
  end
  
  def handle_event("submit_for_generate_prompt", %{"f" => %{"question" => q}}, socket) do
    # TODO: update it.
    template_selected = socket.assigns.template_selected

    search_result_filtered = socket.assigns.search_result_filtered
    build_codes = build_code(search_result_filtered)
    type = search_result_filtered |> Enum.fetch!(0) |> Map.fetch!(:metadata) |> Map.fetch!(:type)
    prompt_final = TemplateHandler.gen_prompt(template_selected.content, %{type: type, codes: build_codes, question: q})
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
            - Self-learning & Self-teaching Copilot based on AI -
          </span>
        </.h2>
        <.h5>Learning and teaching everything assisted by AI.</.h5>
      </center>
    </.container> 
    <!-- Vector Dataset Interactor-->

    <.container class="mt-10">  
      <center>
        <.simple_form for={@form} phx-change="validate" phx-submit="submit">
          <.h3>- Interact with <a href="https://embedbase.xyz/" target="_blank" style="color:blue">Embedbase</a> -</.h3>

          <.p>
            Submit a proposal to the public vector datasets by 
            <a href="https://vector-dataset-governancer.vercel.app/" target="_blank" style="color:blue">Governancer dApp</a>, 
            Or see the proposals in
            <a href="/proposal_viewer" target="_blank" style="color:blue">Proposal Panel</a>.
          </.p>

          <.p>Select the Embedbase Vector Dataset:</.p>
          <.select options={["aptos-smart-contracts-fragment-by-structure": "aptos-smart-contracts-fragment-by-structure"]} form={@form} field={:select_dataset} />
          <.p>Or Input the <a href="https://app.embedbase.xyz/datasets" target="_blank" style="color:blue">Public Dataset</a> Name:</.p>
          <.text_input form={@form} field={:dataset_name} placeholder="eg. web3-dataset" />
          <.p>Ask for Query:</.p>
          <.text_input form={@form} field={:question} placeholder="input anything to query." value="Give me the examples about struct."/>
          <.button color="secondary" label="Search!" variant="outline" />
        </.simple_form>
      </center>

      <%= if not is_nil(assigns[:search_result]) do %>
        <.p>Search Results in Dataset: </.p>
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

        <center>
          <.simple_form for={@form_filter} phx-submit="submit_for_filter">
            <.p>Type the metadata for second time filter:</.p>
            <.p>Key:</.p>
            <.text_input form={@form_filter} field={:key} value="type" placeholder="type" />
            <.p>Value:</.p>
            <.text_input form={@form_filter} field={:value} value="struct" placeholder="struct" />
            <.button color="secondary" label="Filter!" variant="outline" />
          </.simple_form>
        </center>

        <center>
        </center>
      <% end %>

      <%= if not is_nil(assigns[:search_result_filtered]) do %>

      <.p>Search Results in Dataset that be filtered: </.p>
        <.table>
          <thead>
            <.tr>
              <.th>Result</.th>
              <.th>Metadata</.th>
            </.tr>
          </thead>
          <tbody>
          <%= for elem <- assigns[:search_result_filtered] do %>
            <.tr>
              <.td><%= elem.data %></.td>
              <.td><%= inspect(elem.metadata) %></.td>
            </.tr>
          <% end %>
          </tbody>
        </.table>
      
      <center>
        <.simple_form for={@form_prompt_generator} phx-submit="submit_for_generate_prompt">
        <.p>Question:</.p>
        <.text_input form={@form_prompt_generator} field={:question} value="Please Generate a struct which named AddressAggregator." placeholder="question" />
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
            <!-- %{content: "You are a Move smart contract expert. There are the examples of {type} in Move Smart Contract. Here are the code examples of {}.\n{codes}\n {Question}", id: 4, is_default: false, model: nil, title: "GenerateMoveCode"} -->
          <% end %>
          </div>
        </.simple_form>
      </center> 
      <br><br>


        <%= if not is_nil(assigns[:prompt_final]) do %>
          <%= raw(Earmark.as_html!(assigns[:prompt_final]))%>
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

    <!-- Guides -->

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

    <!-- Good Projects -->

    <.container class="mt-10">  
      <center>
        <.h3>❤️ Awesome AI ❤️</.h3>
      </center>
    </.container> 

    <.container class="mt-10">
    <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-3">
      <.card>
        <br>
        <center>
          <.card_media src={~p"/images/logo_lynx.png"} style="width: 50%"/>
        </center>

        <.card_content category="Solution" heading="LynxAI">
          Lynx AI aims to leverage the cognitive capabilities of AI large models, extensively debug them using enterprise private data and industry knowledge, and precisely tailor them to specific business scenarios. 
        </.card_content>

        <.card_footer>
        <.badge color="secondary" label="Lynx" />
        <br><br>
        <a
          target="_blank"
          href="https://lynxai.cn/"
        >
          <.button label="View">
            View
          </.button>
        </a>
        </.card_footer>
      </.card>


      <.card>
        <br>
        <center>
          <.card_media src={~p"/images/logo_embedbase.png"} style="width: 50%"/>
        </center>

        <.card_content category="Dataset" heading="Embedbase">
          A unified API to build AI apps.
        </.card_content>

        <.card_footer>
        <br><br>
        <a
          target="_blank"
          href="https://embedbase.xyz/"
        >
          <.button label="View">
            View
          </.button>
        </a>
        </.card_footer>
      </.card>

      <.card>
        <br>
        <center>
          <.card_media src={~p"/images/logo_flowgpt.png"} style="width: 50%"/>
        </center>

        <.card_content category="Prompt" heading="FlowGPT">
          FIND & USE THE BEST PROMPTS.
        </.card_content>

        <.card_footer>
        <br><br>
        <a
          target="_blank"
          href="https://flowgpt.com/"
        >
          <.button label="View">
            View
          </.button>
        </a>
        </.card_footer>
      </.card>

      <!--<.card>
        <br>
        <center>
          <.card_media src={~p"/images/logo_embedbase.png"} style="width: 50%"/>
        </center>

        <.card_content category="Search" heading="Chainintel">
          The Web3 * AI data analysis tool supports the analysis of multi-chain on-chain data, and combines data and public opinion in a visual way for project analysis and market attribution.
        </.card_content>

        <.card_footer>
        <br><br>
        <a
          target="_blank"
          href="https://embedbase.xyz/"
        >
          <.button label="View">
            View
          </.button>
        </a>
        </.card_footer>
      </.card>-->

    </div>
    </.container> 
    <br><hr>
    <.container class="mt-10">
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
