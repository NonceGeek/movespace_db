defmodule ChatProgrammingWeb.PageLive do
  alias ChatProgramming.{Space, Card}
  alias ChatProgramming.ChatServiceInteractor
  use ChatProgrammingWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    spaces = Space.all()
    space_names = Enum.map(spaces, & &1.name)
    space_selected = Enum.at(spaces, 0)

    {:ok,
     assign(
       socket,
       form: to_form(%{}, as: :f),
       # spaces
       space_names: space_names,
       spaces: spaces,
       space_selected: space_selected
     )}
  end

  


  def handle_params(_, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", %{"f" => %{"select_dataset" => dataset_selected, "dataset_name" => dataset_name, "question" => q}}, socket) do
    embedbase_id = select_dataset(dataset_selected, dataset_name)
    search(embedbase_id, q, socket)
  end

  def search(embedbase_id, question, socket) do
    # search the dataset about the question.
    {:ok, %{similarities: similarities}} = 
      EmbedbaseInteractor.search_data(embedbase_id, question)
    IO.puts inspect similarities
    
    {
      :noreply, 
      assign(socket,
        search_result: similarities
      )
    }
  end

  def select_dataset(dataset_selected, ""), do: dataset_selected
  def select_dataset(_, dataset_name), do: dataset_name

  def handle_event(_others, params, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
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
          <.p>Select the Embedbase Vector Dataset:</.p>
          <.select options={["aptos-smart-contracts-fragment-by-structure": "aptos-smart-contracts-fragment-by-structure"]} form={@form} field={:select_dataset} />
          <.p>Or Input the <a href="https://app.embedbase.xyz/datasets" target="_blank" style="color:blue">Public Dataset</a> Name:</.p>
          <.text_input form={@form} field={:dataset_name} placeholder="eg. web3-dataset" />
          <.p>Ask for Query:</.p>
          <.text_input form={@form} field={:question} placeholder="input anything to query." />
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
        <center>
          <.card_media src={~p"/images/logo_readme.png"} style="width: 50%"/>
        </center>

        <.card_content category="Solution" heading="Web3 Readme Generator">
          Generate Web3 Readme.md for User, Repo & Organization.
        </.card_content>

        <.card_footer>
        <.badge color="secondary" label="Lynx" />
        <br><br>
        <a
          target="_blank"
          href="/readme_generator"
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
          <.card_media src={~p"/images/logo_embedbase.jpeg"} style="width: 50%"/>
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

    </div>
    </.container> 
    <!--<.form for={@form} phx-change="change_space" phx-submit="submit">
      <.container class="mt-10 mb-32">
        <.h3 label="" />
        <div>
          <.input field={@form[:space_name]} type="select" options={@space_names} />
          <br />
          <.h5><%= @space_selected.description %></.h5>
          <br />
          <.input field={@form[:question]} placeholder="How can I learn this technical?" />
          <br />
          <.button color="pure_white" label="Get Answer ⏎" />
          <br><br>
          <%= if is_nil(assigns[:answer]) do %>
            <.h5>Waiting for answer...</.h5>
          <% else %>
            <.h5><%= raw(Earmark.as_html!(assigns[:answer])) %></.h5>
          <% end %>

          <br><br>
          <%= if is_nil(assigns[:history]) do %>
          <% else %>
          <.h5 label="Chat History" />
            <div class="p-1 mt-5 overflow-auto">
              <.table>
                <thead>
                  <.tr>
                    <.th>Histories</.th>
                  </.tr>
                </thead>
                <tbody>
                  <%= for history <- assigns[:history] do %>
                    <.tr>
                      <.td>
                        <%= raw(Earmark.as_html!(history))%>
                      </.td>
                    </.tr>
                  <% end %>
                </tbody>
              </.table>
            </div>
          <br><br>
          <.h5>The Questions that recommend: </.h5>
          <a href="/?q=1">
            <div class="flex items-start">
              <.alert color="info" label="Give me a programming exercise on Python data structures." />
            </div>
          </a>
          <a href="/?q=2">
          <div class="flex items-start mt-4">
            <.alert color="success" label="Give me an exercise on if statements in Python." />
          </div>
          </a>
          <a href="/?q=2">
          <div class="flex items-start mt-4">
            <.alert color="warning" label="Give me an exercise on the for statement in Python." />
          </div>
          </a>
          <% end %>
        </div>
      </.container>

      <.container class="mt-10">
        <.h2 underline label="Question Recommended" />
          <a href="/?q=1">
          <div class="flex items-start mt-4">
            <.alert color="info" label="As a fresh man, how could I learn this technical?" />
          </div>
          </a>
          <a href="/?q=2">
          <div class="flex items-start mt-4">
            <.alert color="success" label="Recommend a real project where I can learn this technique." />
          </div>
          </a>
          <a href="/?q=3">
            <div class="flex items-start mt-4">
              <.alert color="warning" label="Recommand the bounties that I can do." />
            </div>
          </a>
      </.container>

      <.container class="mt-10">
        <.h2 underline label="Knowledge Cards" />
        <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-3">
          <%= for card <- @space_selected.card do %>
            <a href={"#{card.url}"} target="_blank">
              <.card variant="outline">
                <.card_content category={"#{@space_selected.name}"} heading={"#{card.title}"}>
                  <%= card.context %>
                </.card_content>
              </.card>
            </a>
          <% end %>
        </div>
      </.container>

      <.container class="mt-10">
        <.h2 underline label="Experts Recommandation" />
        <div class="grid gap-5 mt-5 md:grid-cols-2 lg:grid-cols-3">
          <%= for expert <- @space_selected.expert do %>
            <a href={"#{expert.url}"} target="_blank">
              <.card variant="outline">
                <.card_content category={"#{@space_selected.name}"} heading={"#{expert.name}"}>
                  <.avatar
                    size="xl"
                    src="https://res.cloudinary.com/wickedsites/image/upload/v1604268092/unnamed_sagz0l.jpg"
                  />
                  <br>
                  <%= expert.description %>
                </.card_content>
              </.card>
            </a>
          <% end %>
        </div>
      </.container>
    </.form>-->
    """
  end
end
