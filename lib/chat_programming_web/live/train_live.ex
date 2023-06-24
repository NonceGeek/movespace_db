defmodule ChatProgrammingWeb.TrainLive do
  @moduledoc """
    https://stackoverflow.com/questions/72758187/openai-gpt-3-api-fine-tune-a-fine-tuned-model
    https://openai.com/api/pricing/#faq-fine-tuning-pricing-calculation
    If you read the Fine-tuning documentation the only part talking about "fine-tuning a fine-tuned model" is the following part under Advanced usage:

    Continue fine-tuning from a fine-tuned model
    If you have already fine-tuned a model for your task and now have additional training data that you would like to incorporate, you can continue fine-tuning from the model. This creates a model that has learned from all of the training data without having to re-train from scratch.

    To do this, pass in the fine-tuned model name when creating a new fine-tuning job (e.g., -m curie:ft-<org>-<date>). Other training parameters do not have to be changed, however if your new training data is much smaller than your previous training data, you may find it useful to reduce learning_rate_multiplier by a factor of 2 to 4.

    Which option to choose?
    You're asking about two options:

    Option 1: ada + bigger-training-dataset.jsonl
    Option 2: ada:ft-acme-inc-2022-06-25 + additional-training-dataset.jsonl
    The documentation says nothing about which option is better in terms of which would yield better results.

    However...

    Choose Option 2
    Why?

    When training a fine-tuned model, the total tokens used will be billed according to our training rates.

    If you choose Option 1, you'll pay for some tokens in your training dataset twice. First when doing fine-tuning with initial training dataset, second when doing fine-tuning with bigger training dataset (i.e., bigger-training-dataset.jsonl = initial-training-dataset.jsonl + additional-training-dataset.jsonl).

    It's better to continue fine-tuning from a fine-tuned model because you'll pay only for tokens in your additional training dataset.

    Read more about fine-tuning pricing calculation.
  """
  alias ChatProgramming.{Space, Card}
  alias ChatProgramming.ExChatServiceInteractor
  alias ChatProgramming.Accounts
  use ChatProgrammingWeb, :live_view
  alias ChatProgramming.{Uploads}
  alias ChatProgramming.{OpenAIFile, ModelHandler, OpenAIFinetuneHistory, OpenAIModel}

  @impl true
  def mount(_any, _session, socket) do
    current_user =
      Accounts.preload(socket.assigns.current_user)
    user_uploads = Uploads.list_uploads(current_user)
    openai_uploads = get_openai_uploads(user_uploads)
    trainable_models = ModelHandler.models(:trainable)
    finetune_id =
      OpenAIFinetuneHistory.get_latest_one()
      |> get_finetune_id()
    finetune_history = ModelHandler.get_finetune(finetune_id)
    {:ok,
    socket
    |> assign(
        current_user: current_user,
        user_uploads: user_uploads,
        uploaded_files: [],
        openai_uploads: openai_uploads,
        trainable_models: trainable_models,
        finetune_id: finetune_id,
        finetune_history: finetune_history,
        form: to_form(%{}, as: :f),
      )
      |> allow_upload(:training_files, accept: :any, max_entries: 3)
    }
  end

  def get_finetune_id(nil), do: nil
  def get_finetune_id(%{unique_id: unique_id}), do: unique_id

  def get_openai_uploads(user_uploads) do
    user_uploads
    |> Enum.map(&(&1.openai_file))
    |> Enum.reject(&(is_nil(&1)))
  end

  @impl true
  def handle_params(_, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :training_files, ref)}
  end

  def handle_event("clear-uploads", _session, socket) do
    res = Accounts.delete_uploads(socket.assigns.current_user)
    current_user =
      Accounts.preload(socket.assigns.current_user)
    {:noreply,
      assign(socket,
      current_user: current_user,
      user_uploads: [],
      uploaded_files: [],
    )}
  end

  def handle_event("save", _params, socket) do
    current_user = socket.assigns.current_user

    uploaded_files =
      consume_uploaded_entries(socket, :training_files, fn %{path: path}, %{client_name: client_name} ->
        dest =
          Path.join([:code.priv_dir(:chat_programming), "static", "uploads", Path.basename(path)])

        File.cp!(path, dest)

        Uploads.create_upload(%{
          user_id: current_user.id,
          path: Path.basename(path),
          name: client_name
        })
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    {:noreply,
      socket
      |> update(:uploaded_files, &(&1 ++ uploaded_files))
      |> assign(:user_uploads, Uploads.list_uploads(current_user))}
  end

  @impl true
  def handle_event("upload-file-to-openai", _params, socket) do
    current_user =
      Accounts.preload(socket.assigns.current_user)
    %{id: upload_id} = upload =
    case get_file_selected_state(socket) do
      nil ->
        Enum.fetch!(current_user.upload, 0) # return the first elem if not select anything.
      upload_id ->
        Uploads.get_upload!(upload_id)
    end
    {:ok,
    %{
      id: unique_id,
    }} = OpenAI.files_upload("priv/static/uploads/#{upload.path}", purpose: "fine-tune")
    {:ok, %{file_unique_id: file_unique_id, id: file_id} = _file} =
      OpenAIFile.create(%{file_unique_id: unique_id, upload_id: upload_id})
    # refresh
    user_uploads = Uploads.list_uploads(current_user)
    openai_uploads = get_openai_uploads(user_uploads)
    {
      :noreply, socket
      |> put_flash(:info, "upload success! file_id: #{file_unique_id}")
      |> assign(openai_uploads: openai_uploads)
      |> assign(file_id: file_id)
    }
  end

  def get_file_selected_state(%{assigns: assigns}), do: Map.get(assigns, :file_selected_state)
  def get_openai_file_selected_state(%{assigns: assigns}), do: Map.get(assigns, :openai_file_selected_state)
  @impl true
  def handle_event("save-history", %{"_target" => ["f", "file_selected"], "f" => %{"file_selected" => selected}}, socket) do
    {
      :noreply,
      assign(socket,
        file_selected_state: selected
      )
    }
  end

  @impl true
  def handle_event("save-history", %{"_target" => ["f", "openai_file_selected"], "f" => %{"openai_file_selected" => openai_file_selected}}, socket) do

    {:noreply, assign(socket, :openai_file_selected_state, openai_file_selected)}
  end

  def handle_event("save-history", %{"_target" => ["f", "model_name"], "f" => %{"model_name" => model_name}}, socket) do

    {:noreply, assign(socket, :model_name, model_name)}
  end

  @impl true
  def handle_event(
    "train-model",
    _params,
    socket) do
    model_name = socket.assigns.model_name
    train_file_unique_id =
    case get_openai_file_selected_state(socket) do
      nil ->
        socket.assigns.openai_uploads |> Enum.fetch!(0) |> Map.fetch!(:file_unique_id) # return the first elem if not select anything.
      unique_id ->
        unique_id
    end

    # create finetune
    {:ok, %{id: finetune_id}} =
      OpenAI.finetunes_create(training_file: train_file_unique_id, model: model_name)
    %{id: file_id} = OpenAIFile.get_by_unique_id(train_file_unique_id)
    {:ok, _fine_tune} = OpenAIFinetuneHistory.create(%{unique_id: finetune_id, openai_file_id: file_id})

    finetune_history = ModelHandler.get_finetune(finetune_id)
    {
      :noreply,
      socket
      |> put_flash(:info, "create finetune success: #{finetune_id}")
      |> assign(:finetune_id, finetune_id)
      |> assign(:finetune_history, finetune_history)
    }
  end

  @impl true
  def handle_event("refresh-finetune", _params, socket) do
    finetune_history = ModelHandler.get_finetune(socket.assigns.finetune_id)
    {
      :noreply,
      socket
      |> assign(:finetune_history, finetune_history)
    }
  end

  @impl true
  def handle_event("check-if-success", params, socket) do
    finetune_id = socket.assigns.finetune_id
    finetune_history = ModelHandler.get_finetune(finetune_id)
    state = ModelHandler.check_finetuen_state(finetune_history)
    model_name = ModelHandler.get_model_name(finetune_history)
    handle_local_model_by_state(state, model_name, finetune_id)
    {
      :noreply,
      socket
      |> put_flash(:info, "if finetuned?: #{state}, model_name: #{model_name}")
    }
  end

  def handle_local_model_by_state(false, _model_name,  _finetune_id), do: {:ok, "finetune not done."}
  def handle_local_model_by_state(true, model_name, finetune_id) do
    id =
    case OpenAIModel.get_by_unique_id(model_name) do
      nil ->
        {:ok, %{id: id}} = OpenAIModel.create(%{model_unique_id: model_name})
        id
      %{id: id} ->
        id
    end
    # create relationships.
    finetune = OpenAIFinetuneHistory.get_by_unique_id(finetune_id)
    OpenAIFinetuneHistory.update(finetune, %{openai_model_id: id})
  end



  @impl true
  def handle_event(others, params, socket) do
    IO.puts inspect others
    IO.puts inspect params
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="flex">

        <div class="w-full">
          <center>
          <.h2>通过文件训练</.h2>


          <.container class="mt-10">
            <.h3 class="mt-10">上传文件</.h3>

            <form id="upload-form" phx-submit="save" phx-change="validate">
                <.live_file_input upload={@uploads.training_files}/>
                <.button color="secondary" label="Upload" type="submit" variant="shadow" />
            </form>

            <section phx-drop-target={@uploads.training_files.ref}>
              <%!-- render each training_files entry --%>
              <%= for entry <- @uploads.training_files.entries do %>
                <article class="upload-entry">
                  <figure>
                    <figcaption><%= entry.client_name %></figcaption>
                  </figure>

                  <%!-- entry.progress will update automatically for in-flight entries --%>
                  <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

                  <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
                  <button
                    type="button"
                    phx-click="cancel-upload"
                    phx-value-ref={entry.ref}
                    aria-label="cancel"
                  >
                    &times;
                  </button>

                  <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                  <%= for err <- upload_errors(@uploads.training_files, entry) do %>
                    <p class="alert alert-danger"><%= error_to_string(err) %></p>
                  <% end %>
                </article>
              <% end %>

              <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
              <%= for err <- upload_errors(@uploads.training_files) do %>
                <p class="alert alert-danger"><%= error_to_string(err) %></p>
              <% end %>
            </section>

            <.h3>已上传 Chat Programming 的文件</.h3>

            <ul>
              <li>
                <%= for item <- @user_uploads do %>
                  <.card class="max-w-sm" variant="outline">
                    <.card_content>
                      <a href={~p"/uploads/#{item.path}"} target="_blank">
                        <%= item.name %>
                      </a>
                    </.card_content>
                  </.card>
                <% end %>
              </li>
            </ul>

            <br>

            <.button
            phx-click="clear-uploads"
            color="danger" label="一忘皆空" variant="outline" />
          <br><br><hr><br>
          <.simple_form
            for={@form}
            id="openai-form"
            phx-submit="openai-submit"
            phx-change="save-history"
            method="post"
          >
            <.select
              options={Enum.map(@user_uploads, fn user_upload -> {user_upload.name, user_upload.id} end)}
              form={@form}
              field={:file_selected}
              value={assigns[:file_selected_state]}
            />
            <.button
              phx-click="upload-file-to-openai"
              color="danger" label="上传文件到 OPENAI" variant="outline" />

          <.h3>已上传 OpenAI 的文件</.h3>
          <.select
            options={Enum.map(@openai_uploads, fn openai_upload -> {openai_upload.file_unique_id, openai_upload.file_unique_id} end)}
            form={@form}
            field={:openai_file_selected}
            value={assigns[:openai_file_selected_state]}
          />
          <br><br><hr><br>
          <.h3>已有模型信息</.h3>
          <.table>
            <thead>
              <.tr>
                <.th>Model ID</.th>
              </.tr>
            </thead>
            <tbody>
              <%= for trainable_model <- @trainable_models do %>
                <.tr>
                  <.td><%= trainable_model.id %></.td>
                </.tr>
              <% end %>
            </tbody>
          </.table>
          <.input field={@form[:model_name]} value={assigns[:model_name]} label="模型名称( ada, babbage, curie, davinci，或者你自己的模型↑)"  />
            <.button
            phx-click="train-model"
            color="danger" label="训练！" variant="outline" />

          <%= if not is_nil(assigns[:finetune_id]) do %>
            <.p>FineTune Id</.p>
            <.p><%= assigns[:finetune_id] %></.p>
            <.p><%= inspect(assigns[:finetune_history])%></.p>
          <% end %>
            <.button
            phx-click="refresh-finetune"
            color="danger" label="刷新训练记录" variant="outline" />
            <.button
            phx-click="check-if-success"
            color="danger" label="检查训练结果" variant="outline" />
          </.simple_form>
          </.container>
          </center>
          <br><br>

        </div>
      </div>
    """
  end


  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
