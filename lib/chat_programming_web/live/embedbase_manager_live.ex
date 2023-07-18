defmodule ChatProgrammingWeb.EmbedbaseManagerLive do
    use ChatProgrammingWeb, :live_view
    alias ChatProgramming.{Uploads, Accounts}
  
    @impl true
    def mount(_params, _session, socket) do
      current_user =
        Accounts.preload(socket.assigns.current_user)
      user_uploads = Uploads.list_uploads(current_user)
      {
        :ok, 
        socket
        |> assign(
          user_uploads: user_uploads,
          uploaded_files: [],
          form: to_form(%{}, as: :f),
        )
        |> allow_upload(:raw_files, accept: :any, max_entries: 3)
        |> allow_upload(:raw_files_md, accept: :any, max_entries: 3)
      }
    end

    @impl true
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

    @impl true
    def handle_event("save", _params, socket) do
      current_user = socket.assigns.current_user
      uploaded_files =
        consume_uploaded_entries(socket, :raw_files, fn %{path: path}, %{client_name: client_name} ->
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
    def handle_event(key, params, socket) do
      IO.puts inspect key
      IO.puts inspect params
      {:noreply, socket}
    end
  
    def handle_params(_params, _url, socket) do
      {:noreply, socket}
    end
  
    @impl true
    def render(assigns) do
      ~H"""
      <.container class="mt-10">
        <center>
        <.h2>Vector Dataset Handler</.h2>
        <.h2>Embedbase & Arweave</.h2>
        
        <hr>
        <.h3> 将 Markdown 文档转换为 JSON: </.h3>
        <form id="upload-form" phx-submit="save-md" phx-change="validate-md">
            <.live_file_input upload={@uploads.raw_files_md}/>
            <.button color="secondary" label="上传 MARKDOWN 压缩包（ZIP）" type="submit" variant="shadow" />
        </form>
        <br><hr><br>
        <!-- UPLOAD FILES -->
        <.h3>选择本地 JSON 文件包上传：</.h3>
        <form id="upload-form" phx-submit="save" phx-change="validate">
            <.live_file_input upload={@uploads.raw_files}/>
            <.button color="secondary" label="上传 JSON 压缩包（ZIP）" type="submit" variant="shadow" />
        </form>
        <br><hr><br>
        <.h3>已上传服务器的文件</.h3>

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
          color="danger" label="清空文件列表" variant="outline" />
        <br>
        <.form_label field={"请输入向量数据库的名称: "} />
        <.text_input field={:text_input} placeholder="Example Vector Dataset" />
        <br>
        <.button
          phx-click="upload-to-embedbase"
          color="danger" label="to Embedbase!" variant="outline" />
        <br><br>
        <.button
          phx-click="upload-to-arweave"
          color="danger" label="to Arweave Network!" variant="outline" />
        <br><br><hr><br>
        <.h2>Arewave & Embedbase Interctor</.h2>
        <.form_label field={"请输入向量数据库的名称: "} />
        <.text_input field={:text_input} placeholder="Example Vector Dataset" />
        <br><br>
        <.button
          phx-click="upload-to-embedbase"
          color="danger" label="将 Embedbase 上的向量数据库传到 Arweave" variant="outline" />
        <br><br>
        <.button
          phx-click="upload-to-arweave"
          color="danger" label="将 Arweave 上的向量数据库传到 Embedbase" variant="outline" />

        <br><br><hr><br>
        <.h2>Vector Dataset Querier</.h2>
        <.form_label field={"请输入向量数据库的名称: "} />
        <.text_input field={:text_input} placeholder="Example Vector Dataset" />
        <br>
        <.button
          phx-click="upload-to-embedbase"
          color="danger" label="访问向量数据库" variant="outline" />

        <.button
        phx-click="upload-to-embedbase"
        color="danger" label="向量数据库使用指南" variant="outline" />
      </center>
      </.container>
      """
    end
  end