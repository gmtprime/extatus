defmodule Extatus.Process do
  @moduledoc """
  This module defines a behaviour to instrument a `GenServer`s.

  For an uninstrumented `GenServer` process, i.e: 

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

  It is necessary to provide the metric definition and the function definitions
  for `get_name/1` and `report/1`. `get_name/1` is used to generate a name for
  the process used as a label in Prometheus and the `report/1` function is to
  report the custom metrics to Prometheus. Both functions receive the current
  `GenServer` state. So, the instrumentating the previous `GenServer`, i.e:
  
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
  """

  @doc """
  Gets the name of the proccess from its `state`.
  """
  @callback get_name(state :: term) :: {:ok, term} | {:error, term}

  @doc """
  Gets the metrics from the process `state`.
  """
  @callback report(state :: term) :: term

  defmacro __using__(_) do
    quote do
      @behaviour Extatus.Process
      use Extatus.Metric

      @doc false
      def get_name(state), do: {:ok, :erlang.phash2(state)}

      @doc false
      def report(_state), do: :ok

      defoverridable [get_name: 1, report: 1]
    end
  end
end
