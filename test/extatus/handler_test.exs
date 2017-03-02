defmodule Extatus.HandlerTest do
  use ExUnit.Case, async: true

  defmodule TestProcess do
    use GenServer
    use Extatus.Process

    defstruct [:name, :module]
    alias __MODULE__, as: State

    def start_link(name) do
      GenServer.start_link(__MODULE__, %State{name: name, module: __MODULE__})
    end

    def stop(pid), do: GenServer.stop(pid)

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

    def get_name(%State{name: name}), do: {:ok, name}

    def report(%State{name: name, module: module}) do
      {Counter, spec} = gen_spec(@metric, name: name, module: module)
      @counter_mod.inc(spec)
    end

    # Callbacks

    def init(%State{} = state), do: {:ok, state}
  end

  alias Extatus.Handler
  alias Extatus.Sandbox.Metric
  alias Extatus.Sandbox.Counter
  alias Extatus.Sandbox.Gauge

  test "start / stop" do
    name = UUID.uuid4()
    {:ok, pid} = TestProcess.start_link(name)
    assert {:ok, handler} = Handler.start_link(TestProcess, pid)
    assert :ok = Handler.stop(handler)
    TestProcess.stop(pid)
  end

  test "metrics" do
    name = UUID.uuid4()
    {:ok, pid} = TestProcess.start_link(name)
    assert {:ok, handler} = Handler.start_link(TestProcess, pid)

    Metric.subscribe(handler)

    activity_metric = :extatus_process_activity
    assert_receive {:declare, {^handler, Gauge, ^activity_metric}, [:name]}
    assert_receive {:set, {^handler, Gauge, ^activity_metric, [^name]}, 2}

    process_metric = :test_process
    assert_receive {:declare, {^handler, Counter, ^process_metric}, [:module, :name]}
    assert_receive {:inc, {^handler, Counter, ^process_metric, [_, ^name]}, inc}
    assert is_integer(inc)
    
    assert :ok = TestProcess.stop(pid)
    assert_receive {:set, {^handler, Gauge, ^activity_metric, [^name]}, 0}

  end
end
