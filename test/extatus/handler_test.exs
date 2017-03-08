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
      Counter.inc(@metric, [name: name, module: module])
    end

    # Callbacks

    def init(%State{} = state), do: {:ok, state}
  end

  alias Extatus.Handler
  alias Extatus.Sandbox.Metric
  alias Extatus.Sandbox.Counter
  alias Extatus.Sandbox.Gauge
  alias Yggdrasil.Channel
  alias Extatus.Message

  test "start / stop" do
    name = UUID.uuid4()
    {:ok, pid} = TestProcess.start_link(name)
    assert {:ok, handler} = Handler.start_link(TestProcess, pid)
    assert :ok = Handler.stop(handler)
    TestProcess.stop(pid)
  end

  test "metrics" do
    channel = %Channel{name: :extatus, adapter: Yggdrasil.Elixir}
    assert :ok = Yggdrasil.subscribe(channel)
    assert_receive {:Y_CONNECTED, _}
    name = UUID.uuid4()
    {:ok, pid} = TestProcess.start_link(name)
    assert {:ok, handler} = Handler.start_link(TestProcess, pid)

    Metric.subscribe(handler)

    activity_metric = :extatus_process_activity
    assert_receive {:declare, Extatus.Sandbox.Gauge, spec, nil}
    assert spec[:name] == activity_metric
    assert spec[:labels] == [:name]
    assert_receive {:set, Extatus.Sandbox.Gauge, spec, 2}
    assert spec[:name] == activity_metric
    assert spec[:labels] == [name]
    assert_receive {:Y_EVENT, _, %Message{state: :up, name: ^name}}

    process_metric = :test_process
    assert_receive {:declare, Extatus.Sandbox.Counter, spec, nil}
    assert spec[:name] == process_metric
    assert spec[:labels] == [:module, :name]
    assert_receive {:inc, Extatus.Sandbox.Counter, spec, 1}
    assert spec[:name] == process_metric
    assert spec[:labels] == ["Extatus.HandlerTest.TestProcess", name]
    
    assert :ok = TestProcess.stop(pid)
    assert_receive {:set, Extatus.Sandbox.Gauge, spec, 0}
    assert spec[:name] == activity_metric
    assert spec[:labels] == [name]
    assert_receive {:Y_EVENT, _, %Message{state: :down, name: ^name}}
  end
end
