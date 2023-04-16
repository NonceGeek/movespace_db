defmodule ChatProgramming.TimesSetter do
  @moduledoc """
    reset the times of user question everyday!
  """
  alias ChatProgramming.Permission

  use GenServer
  require Logger

  # @interval 1_000 # for test.
  @interval 24 * 60 * 1_000

  # +-----------+
  # | GenServer |
  # +-----------+
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :time_setter)
  end

  def init(_args) do
    send(self(), :set_time)
    {:ok, :started}
  end

  @spec schedule_set_time :: reference
  def schedule_set_time() do
    Process.send_after(self(), :set_time, @interval)
  end

  def handle_info(:set_time, _expr) do
    # reset all the users with level 0.
    Permission.reset_remaining_times()

    Logger.info("[#{__MODULE__}]done the reset.")
    schedule_set_time()
    {:noreply, nil}
  end

end
