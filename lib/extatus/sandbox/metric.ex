defmodule Extatus.Sandbox.Metric do
  use GenServer

  defstruct [:table, :subscribers]
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
  def gen_data(module, spec, value \\ nil)

  def gen_data(module, spec, nil) do
    key = {self(), module, spec[:name]}
    {key, spec[:labels]}
  end
  def gen_data(module, spec, value) do
    key = {self(), module, spec[:name], spec[:labels]}
    {key, value}
  end

  @doc false
  def declare(module, spec) do
    data = gen_data(module, spec)
    GenServer.call(__MODULE__, {:declare, data})
  end

  @doc false
  def inc(module, spec, value \\ 1) do
    data = gen_data(module, spec, value)
    GenServer.call(__MODULE__, {:inc, data})
  end

  @doc false
  def set(module, spec, value \\ 1) do
    data = gen_data(module, spec, value)
    GenServer.call(__MODULE__, {:set, data})
  end

  @doc false
  def observe(module, spec, amount \\ 1) do
    data = gen_data(module, spec, amount)
    GenServer.call(__MODULE__, {:observe, data})
  end

  @doc false
  def observe_duration(module, spec, f) do
    {time, result} = :timer.tc(fn -> f.() end)
    data = gen_data(module, spec, time)
    GenServer.call(__MODULE__, {:observe, data})
    result
  end

  @doc false
  def subscribe(pid) do
    GenServer.call(__MODULE__, {:subscribe, pid, self()})
  end

  #######################
  # Callbacks definitions

  @doc false
  def init(_) do
    opts = [:set, write_concurrency: true, read_concurrency: true]
    table = :ets.new(:metrics, opts)
    subscribers = %{}
    state = %State{table: table, subscribers: subscribers}
    {:ok, state}
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
    {:declare, {key, value}},
    _from,
    %State{table: table, subscribers: subscribers} = state
  ) do
    with {:ok, labels} <- insert(table, key, value),
         :ok <- send_subscribers(:declare, subscribers, key, labels) do
      {:reply, :ok, state}
    else
      _ ->
        {:reply, :error, state}
    end
  end
  def handle_call(
    {:inc, {key, value}},
    _from,
    %State{table: table, subscribers: subscribers} = state
  ) do
    with {:ok, value} <- increment(table, key, value),
         :ok <- send_subscribers(:inc, subscribers, key, value) do
      {:reply, :ok, state}
    else
      _ ->
        {:reply, :error, state}
    end
  end
  def handle_call(
    {:set, {key, value}},
    _from,
    %State{table: table, subscribers: subscribers} = state
  ) do
    with {:ok, value} <- update(table, key, value),
         :ok <- send_subscribers(:set, subscribers, key, value) do
      {:reply, :ok, state}
    else
      _ ->
        {:reply, :error, state}
    end
  end
  def handle_call(
    {:observe, {key, value}},
    _from,
    %State{table: table, subscribers: subscribers} = state
  ) do
    with {:ok, value} <- update(table, key, value),
         :ok <- send_subscribers(:observe, subscribers, key, value) do
      {:reply, :ok, state}
    else
      _ ->
        {:reply, :error, state}
    end
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
  def send_subscribers(action, subscribers, key, value) do
    pid = elem(key, 0)
    for receiver <- Map.get(subscribers, pid, []) do
      send receiver, {action, key, value}
    end
    :ok
  end

  @doc false
  def insert(table, key, value) do
    case :ets.lookup(table, key) do
      [] ->
        :ets.insert(table, {key, value})
        {:ok, value}
      [{^key, value} | _] ->
        {:ok, value}
    end
  end

  @doc false
  def update(table, {pid, module, name, values} = key, value) do
    case :ets.lookup(table, {pid, module, name}) do
      [] -> :error
      [{_, labels} | _] ->
        if length(labels) == length(values) do
          :ets.insert(table, {key, value})
          {:ok, value}
        else
          :error
        end
    end
  end

  @doc false
  def increment(table, {pid, module, name, values} = key, value) do
    case :ets.lookup(table, {pid, module, name}) do
      [] -> :error
      [{_, labels} | _] ->
        if length(labels) == length(values) do
          value = :ets.update_counter(table, key, {2, value}, {2, 0})
          {:ok, value}
        else
          :error
        end
    end
  end
end
