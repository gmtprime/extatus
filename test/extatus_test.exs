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
      Counter.inc(@metric, [name: name, module: module])
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
    assert_receive {:declare, Extatus.Sandbox.Gauge, spec, nil}
    assert spec[:name] == activity_metric
    assert spec[:labels] == [:name]
    assert_receive {:set, Extatus.Sandbox.Gauge, spec, 2}
    assert spec[:name] == activity_metric
    assert spec[:labels] == [name]

    process_metric = :test_process
    assert_receive {:declare, Extatus.Sandbox.Counter, spec, nil}
    assert spec[:name] == process_metric
    assert spec[:labels] == [:module, :name]
    assert_receive {:inc, Extatus.Sandbox.Counter, spec, 1}
    assert spec[:name] == process_metric
    assert spec[:labels] == ["ExtatusTest.TestProcess", name]
    
    assert :ok = TestProcess.stop(pid)
    assert_receive {:set, Extatus.Sandbox.Gauge, spec, 0}
    assert spec[:name] == activity_metric
    assert spec[:labels] == [name]
  end
end
