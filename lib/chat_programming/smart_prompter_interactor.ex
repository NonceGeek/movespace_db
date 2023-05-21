defmodule ChatProgramming.SmartPrompterInteractor do

  @default_smart_prompter "http://localhost:4001"

  @paths %{
    user:
      %{
        register: "api/users/register",
        login: "api/users/log_in"
      },
    chat:
      %{
        topics: "api/topics",
      },
    templates:
      %{
        create: "api/prompt_templates"
      }
  }
  def register(username, password) do
    # TODO.
  end

  def register(endpoint) do
    body = %{
      user: %{
        email: "test@test.com",
        password: "1234567891011"
      }
    }
    path = "#{endpoint}/#{@paths.user.register}"
    ExHttp.http_post(path, body)
  end

  def login(endpoint) do
    body = %{
      user: %{
        email: "test@test.com",
        password: "1234567891011"
      }
    }
    path = "#{endpoint}/#{@paths.user.login}"
    ExHttp.http_post(path, body)
  end

  def register_agent() do
    {:ok, agent} = Agent.start_link fn -> [] end
    Process.register(agent, :smart_prompter)
  end

  def set_session(endpoint) do
    {
      :ok,
        %{
          email: email,
          token: the_token
        }
    } = login(endpoint)
    pid = Process.whereis(:smart_prompter)
    if is_nil(pid) do
      register_agent()
    else
      Agent.update(pid, fn token -> the_token end)
    end
  end

  def get_session(endpoint) do

    :smart_prompter
    |> Process.whereis()
    |> Agent.get(fn token -> token end)
  end

  def list_topics(endpoint) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.chat.topics}"
    ExHttp.http_get(path, token, 3)
  end

  def create_topic(endpoint, content, prompt_template_id) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.chat.topics}"
    body =
      %{
        topic: %{
          content: content,
          prompt_template_id: prompt_template_id
        }
      }
    ExHttp.http_post(path, body, token, 3)
  end

  # +-----------+
  # | Templates |
  # +-----------+

  def create_template(endpoint, title, content) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.templates.create}"

    body =
      %{
        prompt_template: %{
          title: title,
          content: content
        }
      }
    ExHttp.http_post(path, body, token, 3)
  end

  def list_template(endpoint) do
    token = get_session(endpoint)
    path = "#{endpoint}/#{@paths.templates.create}"
    ExHttp.http_get(path, token, 3)
  end


end
