defmodule Extatus.Metric.CounterTest do
  use ExUnit.Case, async: true

  alias Extatus.Sandbox.Metric

  @metric :counter_test

  defmodule CounterTest do
    use Extatus.Metric

    @metric :counter_test

    defmetrics do
      counter @metric do
        label :label
        registry :default
        help "Counter test"
      end
    end

    def new do
      Counter.new(@metric)
    end

    def declare do
      Counter.declare(@metric)
    end

    def remove(values) do
      Counter.remove(@metric, values)
    end

    def reset(values) do
      Counter.reset(@metric, values)
    end

    def value(values) do
      Counter.value(@metric, values)
    end

    def inc(values) do
      Counter.inc(@metric, values)
    end

    def inc(values, value) do
      Counter.inc(@metric, values, value)
    end

    def dinc(values) do
      Counter.dinc(@metric, values)
    end

    def dinc(values, value) do
      Counter.dinc(@metric, values, value)
    end
  end

  test "new/1" do
    Metric.subscribe(self())
    CounterTest.new()
    spec = [
      help: "Counter test",
      registry: :default,
      labels: [:label],
      name: @metric
    ]
    assert_receive {:new, Extatus.Sandbox.Counter, ^spec, nil}
  end

  test "declare/1" do
    Metric.subscribe(self())
    CounterTest.declare()
    spec = [
      help: "Counter test",
      registry: :default,
      labels: [:label],
      name: @metric
    ]
    assert_receive {:declare, Extatus.Sandbox.Counter, ^spec, nil}
  end

  test "remove/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    CounterTest.remove(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:remove, Extatus.Sandbox.Counter, ^spec, nil}
  end

  test "reset/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    CounterTest.reset(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:reset, Extatus.Sandbox.Counter, ^spec, nil}
  end

  test "value/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    CounterTest.value(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:value, Extatus.Sandbox.Counter, ^spec, nil}
  end

  test "inc/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    CounterTest.inc(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:inc, Extatus.Sandbox.Counter, ^spec, 1}
  end

  test "inc/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    CounterTest.inc(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:inc, Extatus.Sandbox.Counter, ^spec, 42}
  end

  test "dinc/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    CounterTest.dinc(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dinc, Extatus.Sandbox.Counter, ^spec, 1}
  end

  test "dinc/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    CounterTest.dinc(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dinc, Extatus.Sandbox.Counter, ^spec, 42}
  end
end
