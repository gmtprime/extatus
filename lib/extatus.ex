defmodule Extatus do
  @moduledoc """
  Extatus is an application to report the status of `GenServer` processes to
  Prometheus (time series database) via the HTTP endpoint `/metrics`
  implemented with `:cowboy`.

  The metrics `:cowboy_scrape_duration_seconds` (summary) and
  `cowboy_scrape_size_bytes` (summary) are calculated on every request to
  the `/metrics` endpoint.

  Also for every instrumented `GenServer` process, extatus reports the
  metric `:extatus_process_activity` (gauge). This metric indicates that a
  process is up (2), down (0) or idle (1) depending on its value.

  ## Example

  To instrument a `GenServer` is necessary to use the `Extatus.Process`
  behaviour and implement its callbacks (`gen_name/1` and `report/1`) which
  receive the current `GenServer` state as argument. So, for the following
  module:

  ```elixir
  defmodule Uninstrumented do
    use GenServer

    def start_link, do: GenServer.start_link(__MODULE__, nil)

    def stop(pid), do: GenServer.stop(pid)

    def value(pid), do: GenServer.call(pid, :value)

    def inc(pid), do: GenServer.call(pid, :inc)

    def dec(pid), do: GenServer.call(pid, :dec)

    def init(_), do: {:ok, 0}

    def handle_call(:value, _from, n), do: {:reply, {:ok, n}, n}
    def handle_call(:inc, _from, n), do: {:reply, :ok, n + 1}
    def handle_call(:dec, _from, n), do: {:reply, :ok, n - 1}
    def handle_call(_, n), do: {:noreply, n}
  end
  ```

  And the instrumented `GenServer` would be the following:

  ```elixir
  defmodule Instrumented do
    use GenServer
    use Extatus.Process # Extatus.Process behaviour

    def start_link, do: GenServer.start_link(__MODULE__, nil)

    def stop(pid), do: GenServer.stop(pid)

    def value(pid), do: GenServer.call(pid, :value)

    def inc(pid), do: GenServer.call(pid, :inc)

    def dec(pid), do: GenServer.call(pid, :dec)

    # Metric
    defmetrics do
      gauge :instrument_gauge do
        label :label
        registry :default
        help "Instrument gauge"
      end
    end

    # Name of the process. This must be unique.
    def get_name(_n), do: {:ok, "instrumented_process"}

    # Report
    def report(n) do
      Gauge.set(:instrument_gauge, [label: "Label"], n)
    end

    def init(_) do
      {:ok, _} = Extatus.set(__MODULE__, self()) # Add extatus handler.
      {:ok, 0}
    end

    def handle_call(:value, _from, n), do: {:reply, {:ok, n}, n}
    def handle_call(:inc, _from, n), do: {:reply, :ok, n + 1}
    def handle_call(:dec, _from, n), do: {:reply, :ok, n - 1}
    def handle_call(_, n), do: {:noreply, n}
  end
  ```

  This `GenServer` will report the current value stored in the server as the
  metric `:instrument_gauge` to Prometheus.

  Additionally, `Yggdrasil` subscriptions to the channel:

  ```elixir
  %Yggdrasil.Channel{name: :extatus, adapter: Yggdrasil.Elixir}
  ```

  can be used to get the updates on the current state of the process i.e:

  ```elixir
  iex> chan = %Yggdrasil.Channel{name: :extatus, adapter: Yggdrasil.Elixir}
  iex> Yggdrasil.subscribe(chan)
  iex> flush()
  {:Y_CONNECTED, (...)}
  iex> {:ok, _} = Instrumented.start_link()
  {:ok, #PID<0.603.0>}
  iex> flush()
  {:Y_EVENT, _, %Extatus.Message{name: "instrumented_process", state: :up}}
  ```

  ## Configuration

  The following are the configuration arguments available:

    - `:timeout` - Frequency the handlers get the metrics from the processes.
    - `:port` - Port where cowboy is listening to request coming from
    Prometheus.
    - `:prometheus_registry` - Prometheus registry. By default is `:default`.

  i.e:

  ```elixir
  config :extatus,
    timeout: 5000,
    port: 1337,
    prometheus_registry: :test
  ```
  """
  use Application

  @generator Extatus.Generator

  @doc """
  Starts a status handler for the provided `module` and `pid`. Links to
  calling process. This is to avoid having processes without Extatus handlers.
  """
  @spec set(module, pid) :: Supervisor.on_start_child
  def set(module, pid) do
    {:ok, pid} = @generator.start_handler(@generator, module, pid)
    true = Process.link(pid)
    {:ok, pid}
  end

  ###################
  # Application start

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = get_children()

    opts = [strategy: :one_for_one, name: Extatus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc false
  def get_children, do: run_sandbox() |> get_children()

  @doc false
  def run_sandbox do
    Application.get_env(:extatus, :counter_mod) == Extatus.Sandbox.Counter or
    Application.get_env(:extatus, :gauge_mod) == Extatus.Sandbox.Gauge or
    Application.get_env(:extatus, :histogram_mod) == Extatus.Sandbox.Histogram or
    Application.get_env(:extatus, :summary_mod) == Extatus.Sandbox.Summary
  end

  @doc false
  def get_children(true) do
    import Supervisor.Spec, warn: false
    [
      worker(Extatus.Sandbox.Metric, []),
      worker(Extatus.Server, [[name: Extatus.Server]]),
      supervisor(@generator, [[name: @generator]])
    ]
  end
  def get_children(false) do
    import Supervisor.Spec, warn: false
    [
      worker(Extatus.Server, [[name: Extatus.Server]]),
      supervisor(@generator, [[name: @generator]])
    ]
  end
end
