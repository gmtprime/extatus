defmodule ExtatusTest do
  use ExUnit.Case

  defmodule TestProcess do
    use GenServer
    use Extatus.Process

    defstruct [:name, :module, :parent]
    alias __MODULE__, as: State

    def start_link(name) do
      state = %State{name: name, module: __MODULE__, parent: self()}
      GenServer.start_link(__MODULE__, state)
    end

    def stop(pid) do
      GenServer.stop(pid)
    end

    # Metric declaration

    @metric :test_process
    defmetrics do
      counter @metric do
        label :module
        label :name
        registry :default
        help "Test process"
      end
    end

    # Extatus.Process behaviour

    def get_name(%State{name: name}) do
      {:ok, name}
    end

    def report(%State{name: name, module: module}) do
      with {Counter, spec} <- gen_spec(@metric, name: name, module: module) do
        @counter_mod.inc(spec)
        :ok
      else
        _ -> :error
      end
    end

    # Callbacks

    def init(%State{parent: parent} = state) do
      {:ok, pid} = Extatus.set(__MODULE__, self())
      send parent, {:handler, pid}
      {:ok, state}
    end
  end

  alias Extatus.Sandbox.Metric
  alias Extatus.Sandbox.Counter
  alias Extatus.Sandbox.Gauge

  test "Metrics generation" do
    name = UUID.uuid4()
    
    assert {:ok, pid} = TestProcess.start_link(name)
    assert_receive {:handler, handler}
    Metric.subscribe(handler)

    activity_metric = :extatus_process_activity
    assert_receive {:declare, {^handler, Gauge, ^activity_metric}, [:name, :pid, :state]}
    assert_receive {:set, {^handler, Gauge, ^activity_metric, [^name, _, "up"]}, 2}

    process_metric = :test_process
    assert_receive {:declare, {^handler, Counter, ^process_metric}, [:module, :name]}
    assert_receive {:inc, {^handler, Counter, ^process_metric, [_, ^name]}, inc}
    assert is_integer(inc)
    
    assert :ok = TestProcess.stop(pid)
    assert_receive {:set, {^handler, Gauge, ^activity_metric, [^name, _, ":normal"]}, 0}
  end
end
