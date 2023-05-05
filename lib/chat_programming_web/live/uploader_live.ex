defmodule ChatProgrammingWeb.UploaderLive do
  @moduledoc false

  use ChatProgrammingWeb, :live_view

  alias ChatProgramming.{Uploads}

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    user_uploads = Uploads.list_uploads(current_user)
    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:user_uploads, user_uploads)
      |> assign(:uploaded_files, [])
      |> allow_upload(:avatar, accept: ~w(.md .txt), max_entries: 3)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("save", _params, socket) do
    current_user = socket.assigns.current_user

    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, %{client_name: client_name} ->
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
  def render(assigns) do
    ~H"""
    <.container class="mt-10">
      <.h2>List Uploads</.h2>

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

      <.h2 class="mt-10">Upload Form</.h2>

      <form id="upload-form" phx-submit="save" phx-change="validate">
          <.live_file_input upload={@uploads.avatar}/>
          <.button color="secondary" label="Upload" type="submit" variant="shadow" />
      </form>

      <section phx-drop-target={@uploads.avatar.ref}>
        <%!-- render each avatar entry --%>
        <%= for entry <- @uploads.avatar.entries do %>
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
            <%= for err <- upload_errors(@uploads.avatar, entry) do %>
              <p class="alert alert-danger"><%= error_to_string(err) %></p>
            <% end %>
          </article>
        <% end %>

        <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
        <%= for err <- upload_errors(@uploads.avatar) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>
      </section>
    </.container>
    """
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
