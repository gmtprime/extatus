defmodule Extatus.Handler do
  @moduledoc """
  This module defines a handler to monitor processes and check its status.

  It tracks the gauge metric `:extatus_process_activity`. Its meaning is:
  
    - 0 for a process down.
    - 1 for a process idle.
    - 2 for a process up.

  Additionally it has only one label `:name` which should be unique among
  processes. `:name` is the name of the monitored process. See
  `Extatus.Process` behaviour and the callback `gen_name/1`.

  By default gathers data every 1000 milliseconds. To change it, for example,
  to 5000 milliseconds just set the configuration as:

      config :extatus,
        timeout: 5000

  Other processes can subscribe to an `Yggdrasil` channel to get the state
  updates of the process. The channel is:

      (...)
      iex> chan = %Yggdrasil.Channel{name: :extatus, adapter: Yggdrasil.Elixir}
      iex> Yggdrasil.subscribe(chan)
      iex> flush()
      {:Y_EVENT, (...), %Extatus.Message{name: (...), state: :idle}}
  """
  use GenServer
  use Extatus.Metric

  alias Yggdrasil.Channel
  alias Extatus.Message

  @timeout Application.get_env(:extatus, :timeout, 1000)

  defstruct [:pid, :ref, :name, :module, :last_state]
  alias __MODULE__, as: State

  @type state :: :starting | :up | :idle | :down

  @doc """
  Starts a handler with the `module` and the `pid` of the process to monitor
  and some optional `GenServer` `options`.
  """
  @spec start_link(module, pid) :: GenServer.on_start
  @spec start_link(module, pid, GenServer.options) :: GenServer.on_start
  def start_link(module, pid, options \\ []) do
    state = %State{pid: pid, module: module}
    GenServer.start_link(__MODULE__, state, options)
  end

  @doc """
  Stops a `handler` with its name or PID.
  """
  @spec stop(GenServer.name) :: :ok
  @spec stop(GenServer.name, term) :: :ok
  def stop(handler, reason \\ :normal) do
    GenServer.stop(handler, reason)
  end

  #####################
  # GenServer callbacks

  @doc false
  def init(%State{} = state) do
    Process.send_after(self(), :ready_up, 0)
    {:ok, state}
  end

  @doc false
  def handle_info(:ready_up, %State{module: module, pid: pid} = state) do
    setup()
    :ok = module.setup()
    {:ok, name} = get_name(module, pid)
    ref = Process.monitor(pid)
    state = %State{state | ref: ref, name: name} 
    {:noreply, state, 0}
  end
  def handle_info(:timeout, %State{} = state) do
    {:ok, state} = report(state)
    {:noreply, state, @timeout}
  end
  def handle_info(
    {:DOWN, ref, _, pid, _reason},
    %State{pid: pid, ref: ref} = state
  ) do
    {:ok, state} = down(state)
    {:stop, :normal, state}
  end
  def handle_info(_, %State{} = state) do
    {:noreply, state, @timeout}
  end

  ######################
  # Publishing functions

  @doc false
  def publish(%State{name: name, last_state: current}) do
    message = %Message{name: name, state: current}
    channel = gen_extatus_channel()
    Yggdrasil.publish(channel, message)
  end

  @doc false
  def gen_extatus_channel do
    %Channel{name: :extatus, adapter: Yggdrasil.Elixir}
  end

  #########
  # Helpers

  @metric :extatus_process_activity

  defmetrics do
    gauge @metric do
      label :name
      help "Process activity"
      registry :default
    end
  end

  @doc false
  def get_state(pid) do
    try do
      {:ok, :sys.get_state(pid)}
    rescue
      _ -> :error
    end
  end

  @doc false
  def get_name(module, pid) do
    with {:ok, state} <- get_state(pid) do
      {:ok, name} = module.get_name(state)
    else
      :error -> :error
    end
  end

  @doc false
  def up(%State{name: name, last_state: :up} = state) do
    _ = Gauge.set(@metric, [name: name], 2)
    {:ok, state}
  end
  def up(%State{} = state) do
    new_state = %State{state | last_state: :up}
    publish(new_state)
    up(new_state)
  end

  @doc false
  def idle(%State{name: name, last_state: :idle} = state) do
    _ = Gauge.set(@metric, [name: name], 1)
    {:ok, state}
  end
  def idle(%State{} = state) do
    new_state = %State{state | last_state: :idle}
    publish(new_state)
    idle(new_state)
  end

  @doc false
  def down(%State{name: name, last_state: :down} = state) do
    _ = Gauge.set(@metric, [name: name], 0)
    {:ok, state}
  end
  def down(%State{} = state) do
    new_state = %State{state | last_state: :down}
    publish(new_state)
    down(new_state)
  end

  @doc false
  def report(state, %State{module: module}) do
    module.report(state)
  end

  @doc false
  def report(%State{pid: pid} = state) do
    with {:ok, process_state} <- get_state(pid) do
         {:ok, state} = up(state)
         _ = report(process_state, state)
         {:ok, state}
    else
      :error ->
        idle(state)
    end
  end
end
