defmodule Extatus.Metric.HistogramTest do
  use ExUnit.Case, async: true

  alias Extatus.Sandbox.Metric

  @metric :histogram_test

  defmodule HistogramTest do
    use Extatus.Metric

    @metric :histogram_test

    defmetrics do
      histogram @metric do
        label :label
        registry :default
        help "Histogram test"
      end
    end

    def new do
      Histogram.new(@metric)
    end

    def declare do
      Histogram.declare(@metric)
    end

    def remove(values) do
      Histogram.remove(@metric, values)
    end

    def reset(values) do
      Histogram.reset(@metric, values)
    end

    def value(values) do
      Histogram.value(@metric, values)
    end

    def observe(values) do
      Histogram.observe(@metric, values)
    end

    def observe(values, value) do
      Histogram.observe(@metric, values, value)
    end

    def dobserve(values) do
      Histogram.dobserve(@metric, values)
    end

    def dobserve(values, value) do
      Histogram.dobserve(@metric, values, value)
    end

    def observe_duration(values, function) do
      Histogram.observe_duration(@metric, values, function)
    end
  end

  test "new/1" do
    Metric.subscribe(self())
    HistogramTest.new()
    spec = [
      help: "Histogram test",
      registry: :default,
      labels: [:label],
      name: @metric
    ]
    assert_receive {:new, Extatus.Sandbox.Histogram, ^spec, nil}
  end

  test "declare/1" do
    Metric.subscribe(self())
    HistogramTest.declare()
    spec = [
      help: "Histogram test",
      registry: :default,
      labels: [:label],
      name: @metric
    ]
    assert_receive {:declare, Extatus.Sandbox.Histogram, ^spec, nil}
  end

  test "remove/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    HistogramTest.remove(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:remove, Extatus.Sandbox.Histogram, ^spec, nil}
  end

  test "reset/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    HistogramTest.reset(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:reset, Extatus.Sandbox.Histogram, ^spec, nil}
  end

  test "value/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    HistogramTest.value(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:value, Extatus.Sandbox.Histogram, ^spec, nil}
  end

  test "observe/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    HistogramTest.observe(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:observe, Extatus.Sandbox.Histogram, ^spec, 1}
  end

  test "observe/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    HistogramTest.observe(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:observe, Extatus.Sandbox.Histogram, ^spec, 42}
  end

  test "dobserve/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    HistogramTest.dobserve(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dobserve, Extatus.Sandbox.Histogram, ^spec, 1}
  end

  test "dobserve/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    HistogramTest.dobserve(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dobserve, Extatus.Sandbox.Histogram, ^spec, 42}
  end

  test "observe_duration/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    HistogramTest.observe_duration(values, fn -> 42 end)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:observe_duration, Extatus.Sandbox.Histogram, ^spec, time}
    assert is_integer(time)
  end
end
