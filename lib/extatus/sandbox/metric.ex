defmodule Extatus.Sandbox.Metric do
  use GenServer

  defstruct [:subscribers]
  alias __MODULE__, as: State

  @doc """
  Starts a sandbox metric server with some optional `GenServer` `options`.
  """
  def start_link do
    GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
  end

  @doc """
  Stops a sandbox metric server with its `pid` and an optional `reason`.
  """
  def stop do
    GenServer.stop(__MODULE__)
  end

  @doc false
  def gen_data(module, spec, value \\ nil) do
    {self(), module, spec, value}
  end

  @doc false
  def send_data(function, data) do
    GenServer.call(__MODULE__, {function, data})
  end

  @doc false
  def new(module, spec) do
    data = gen_data(module, spec)
    send_data(:new, data)
  end

  @doc false
  def declare(module, spec) do
    data = gen_data(module, spec)
    send_data(:declare, data)
  end

  @doc false
  def inc(module, spec, value \\ 1) do
    data = gen_data(module, spec, value)
    send_data(:inc, data)
  end

  @doc false
  def dinc(module, spec, value \\ 1) do
    data = gen_data(module, spec, value)
    send_data(:dinc, data)
  end

  @doc false
  def dec(module, spec, value \\ 1) do
    data = gen_data(module, spec, value)
    send_data(:dec, data)
  end

  @doc false
  def ddec(module, spec, value \\ 1) do
    data = gen_data(module, spec, value)
    send_data(:ddec, data)
  end

  @doc false
  def set(module, spec, value \\ 1) do
    data = gen_data(module, spec, value)
    send_data(:set, data)
  end

  @doc false
  def set_to_current_time(module, spec) do
    data = gen_data(module, spec, :os.system_time(:seconds))
    send_data(:set_to_current_time, data)
  end

  @doc false
  def track_inprogress(module, spec, function) do
    result = function.()
    data = gen_data(module, spec, result)
    send_data(:track_inprogress, data)
    result
  end

  @doc false
  def set_duration(module, spec, function) do
    {time, result} = :timer.tc(fn -> function.() end)
    data = gen_data(module, spec, time)
    send_data(:set_duration, data)
    result
  end

  @doc false
  def observe(module, spec, amount \\ 1) do
    data = gen_data(module, spec, amount)
    send_data(:observe, data)
  end

  @doc false
  def dobserve(module, spec, amount \\ 1) do
    data = gen_data(module, spec, amount)
    send_data(:dobserve, data)
  end

  @doc false
  def observe_duration(module, spec, f) do
    {time, result} = :timer.tc(fn -> f.() end)
    data = gen_data(module, spec, time)
    send_data(:observe_duration, data)
    result
  end

  @doc false
  def remove(module, spec) do
    data = gen_data(module, spec)
    send_data(:remove, data)
  end

  @doc false
  def reset(module, spec) do
    data = gen_data(module, spec)
    send_data(:reset, data)
  end

  @doc false
  def value(module, spec) do
    data = gen_data(module, spec)
    send_data(:value, data)
  end

  @doc false
  def subscribe(pid) do
    GenServer.call(__MODULE__, {:subscribe, pid, self()})
  end

  #######################
  # Callbacks definitions

  @doc false
  def init(_) do
    {:ok, %State{subscribers: %{}}}
  end

  @doc false
  def handle_call(
    {:subscribe, pid, receiver},
    _from,
    %State{subscribers: subscribers} = state
  ) do
    {:ok, subscribers} = add_subscriber(subscribers, pid, receiver)
    {:reply, :ok, %State{state | subscribers: subscribers}}
  end
  def handle_call(
    {function, {_pid, _module, _spec, _value} = key},
    _from,
    %State{subscribers: subscribers} = state
  ) do
    result = send_subscribers(function, subscribers, key)
    {:reply, result, state}
  end
  def handle_call(_msg, _from, state) do
    {:noreply, state}
  end

  #########
  # Helpers

  @doc false
  def add_subscriber(subscribers, pid, receiver) do
    case Map.pop(subscribers, pid) do
      {nil, subscribers} ->
        {:ok, Map.put(subscribers, pid, [receiver])}
      {receivers, subscribers} ->
        {:ok, Map.put(subscribers, pid, [receiver | receivers])}
    end
  end

  @doc false
  def send_subscribers(function, subscribers, {pid, module, spec, value}) do
    for receiver <- Map.get(subscribers, pid, []) do
      send receiver, {function, module, spec, value}
    end
    :ok
  end
end
