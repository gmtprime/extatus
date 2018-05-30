# Extatus

[![Build Status](https://travis-ci.org/gmtprime/extatus.svg?branch=master)](https://travis-ci.org/gmtprime/extatus) [![Hex pm](http://img.shields.io/hexpm/v/extatus.svg?style=flat)](https://hex.pm/packages/extatus) [![hex.pm downloads](https://img.shields.io/hexpm/dt/extatus.svg?style=flat)](https://hex.pm/packages/extatus)

Extatus is an application that reports metrics to Prometheus via the HTTP
endpoint `/metrics` from an instrumented `GenServer`.

## Small Example

The following is an uninstrumented `GenServer` that tracks its uptime.

```
defmodule Uninstrumented do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def get_uptime(pid) do
    GenServer.call(pid, :uptime)
  end

  def init(_) do
    start_time = :os.system_time(:seconds)
    {:ok, seconds}
  end

  def handle_call(:uptime, _from, start_time) do
    uptime = :os.system_time(:seconds) - start_time
    {:reply, uptime, start_time}
  end
end
```

If we would want to track the uptime of this process in Prometheus with
`Extatus`, we would need:
  1. `use Extatus.Process` behaviour.
  2. Declare a gauge metric to track the uptime e.g. a metric called `:uptime`
     with a label for the module name.
  3. Implement the function `get_name/1` that receives the `GenServer` process
     state and returns the name of the process. This name must be unique.
  4. Implement the function `report/1` that receives the `GenServer` process
     state. In this function, you can report the metrics.
  5. Start the `Extatus` watchdog for your process in the `init/1` function by
     adding the function `add_extatus_watchdog/0` (included by
     `use Extatus.Process`).

```
defmodule Instrumented do
  use GenServer
  use Extatus.Process # Extatus behaviour

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  # Metric declaration
  defmetrics do
    gauge :uptime do
      label :module
      help "Uptime gauge"
    end
  end

  # Name of the process. This must be unique.
  def get_name(_state) do
    {:ok, Atom.to_string(__MODULE__)}
  end

  # Report function
  def report(start_time) do
    uptime = :os.system_time(:seconds) - start_time
    Gauge.set(:uptime, [module: Atom.to_string(__MODULE__)], uptime)
  end

  def init(_) do
    :ok = add_extatus_watchdog() # Add extatus watchdog
    {:ok, :os.system_time(:seconds)}
  end
end
```

The HTTP `/metric` endpoint is implemented in `:cowboy` and the output is
provided by the library `:prometheus_ex`. If you start this process, you will
see the metric `:uptime` being reported.

Additionally, for every instrumented `GenServer` process, extatus reports the
metric `:extatus_process_activity` (gauge). This metric indicates that a
process is up (2), down (0) or idle (1) depending on its value.

`Extatus` uses `Yggdrasil` to report the status of the processes in the
following channel:

```elixir
%Yggdrasil.Channel{name: :extatus}
```

This can be used to get the updates on the current state of the processes in
a subscriber e.g:

```elixir
iex> chan = %Yggdrasil.Channel{name: :extatus}
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

e.g:

```elixir
config :extatus,
  timeout: 5000,
  port: 1337,
  prometheus_registry: :test
```

## Installation

If [available in Hex](https://hex.pm/packages/extatus), the package can be
installed as:

  1. Add `extatus` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:extatus, "~> 0.2"}]
    end
    ```

  2. Ensure `extatus` is started before your application:

    ```elixir
    def application do
      [applications: [:extatus]]
    end
    ```
