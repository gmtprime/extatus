defmodule Extatus.Metric.SummaryTest do
  use ExUnit.Case, async: true

  alias Extatus.Sandbox.Metric

  @metric :summary_test

  defmodule SummaryTest do
    use Extatus.Metric

    @metric :summary_test

    defmetrics do
      summary @metric do
        label :label
        registry :default
        help "Summary test"
      end
    end

    def new do
      Summary.new(@metric)
    end

    def declare do
      Summary.declare(@metric)
    end

    def remove(values) do
      Summary.remove(@metric, values)
    end

    def reset(values) do
      Summary.reset(@metric, values)
    end

    def value(values) do
      Summary.value(@metric, values)
    end

    def observe(values) do
      Summary.observe(@metric, values)
    end

    def observe(values, value) do
      Summary.observe(@metric, values, value)
    end

    def dobserve(values) do
      Summary.dobserve(@metric, values)
    end

    def dobserve(values, value) do
      Summary.dobserve(@metric, values, value)
    end

    def observe_duration(values, function) do
      Summary.observe_duration(@metric, values, function)
    end
  end

  test "new/1" do
    Metric.subscribe(self())
    SummaryTest.new()
    spec = [
      help: "Summary test",
      registry: :default,
      labels: [:label],
      name: @metric
    ]
    assert_receive {:new, Extatus.Sandbox.Summary, ^spec, nil}
  end

  test "declare/1" do
    Metric.subscribe(self())
    SummaryTest.declare()
    spec = [
      help: "Summary test",
      registry: :default,
      labels: [:label],
      name: @metric
    ]
    assert_receive {:declare, Extatus.Sandbox.Summary, ^spec, nil}
  end

  test "remove/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    SummaryTest.remove(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:remove, Extatus.Sandbox.Summary, ^spec, nil}
  end

  test "reset/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    SummaryTest.reset(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:reset, Extatus.Sandbox.Summary, ^spec, nil}
  end

  test "value/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    SummaryTest.value(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:value, Extatus.Sandbox.Summary, ^spec, nil}
  end

  test "observe/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    SummaryTest.observe(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:observe, Extatus.Sandbox.Summary, ^spec, 1}
  end

  test "observe/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    SummaryTest.observe(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:observe, Extatus.Sandbox.Summary, ^spec, 42}
  end

  test "dobserve/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    SummaryTest.dobserve(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dobserve, Extatus.Sandbox.Summary, ^spec, 1}
  end

  test "dobserve/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    SummaryTest.dobserve(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dobserve, Extatus.Sandbox.Summary, ^spec, 42}
  end

  test "observe_duration/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    SummaryTest.observe_duration(values, fn -> 42 end)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:observe_duration, Extatus.Sandbox.Summary, ^spec, time}
    assert is_integer(time)
  end
end
