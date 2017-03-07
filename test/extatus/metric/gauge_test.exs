defmodule Extatus.Metric.GaugeTest do
  use ExUnit.Case, async: true

  alias Extatus.Sandbox.Metric

  @metric :gauge_test

  defmodule GaugeTest do
    use Extatus.Metric

    @metric :gauge_test

    defmetrics do
      gauge @metric do
        label :label
        registry :default
        help "Gauge test"
      end
    end

    def new do
      Gauge.new(@metric)
    end

    def declare do
      Gauge.declare(@metric)
    end

    def remove(values) do
      Gauge.remove(@metric, values)
    end

    def reset(values) do
      Gauge.reset(@metric, values)
    end

    def value(values) do
      Gauge.value(@metric, values)
    end

    def inc(values) do
      Gauge.inc(@metric, values)
    end

    def inc(values, value) do
      Gauge.inc(@metric, values, value)
    end

    def dinc(values) do
      Gauge.dinc(@metric, values)
    end

    def dinc(values, value) do
      Gauge.dinc(@metric, values, value)
    end

    def dec(values) do
      Gauge.dec(@metric, values)
    end

    def dec(values, value) do
      Gauge.dec(@metric, values, value)
    end

    def ddec(values) do
      Gauge.ddec(@metric, values)
    end

    def ddec(values, value) do
      Gauge.ddec(@metric, values, value)
    end

    def set(values, value) do
      Gauge.set(@metric, values, value)
    end

    def set_to_current_time(values) do
      Gauge.set_to_current_time(@metric, values)
    end

    def track_inprogress(values, function) do
      Gauge.track_inprogress(@metric, values, function)
    end

    def set_duration(values, function) do
      Gauge.set_duration(@metric, values, function)
    end
  end

  test "new/1" do
    Metric.subscribe(self())
    GaugeTest.new()
    spec = [
      help: "Gauge test",
      registry: :default,
      labels: [:label],
      name: @metric
    ]
    assert_receive {:new, Extatus.Sandbox.Gauge, ^spec, nil}
  end

  test "declare/1" do
    Metric.subscribe(self())
    GaugeTest.declare()
    spec = [
      help: "Gauge test",
      registry: :default,
      labels: [:label],
      name: @metric
    ]
    assert_receive {:declare, Extatus.Sandbox.Gauge, ^spec, nil}
  end

  test "remove/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.remove(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:remove, Extatus.Sandbox.Gauge, ^spec, nil}
  end

  test "reset/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.reset(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:reset, Extatus.Sandbox.Gauge, ^spec, nil}
  end

  test "value/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.value(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:value, Extatus.Sandbox.Gauge, ^spec, nil}
  end

  test "inc/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.inc(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:inc, Extatus.Sandbox.Gauge, ^spec, 1}
  end

  test "inc/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.inc(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:inc, Extatus.Sandbox.Gauge, ^spec, 42}
  end

  test "dinc/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.dinc(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dinc, Extatus.Sandbox.Gauge, ^spec, 1}
  end

  test "dinc/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.dinc(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dinc, Extatus.Sandbox.Gauge, ^spec, 42}
  end

  test "dec/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.dec(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dec, Extatus.Sandbox.Gauge, ^spec, 1}
  end

  test "dec/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.dec(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:dec, Extatus.Sandbox.Gauge, ^spec, 42}
  end

  test "ddec/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.ddec(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:ddec, Extatus.Sandbox.Gauge, ^spec, 1}
  end

  test "ddec/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.ddec(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:ddec, Extatus.Sandbox.Gauge, ^spec, 42}
  end

  test "set/2" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.set(values, 42)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:set, Extatus.Sandbox.Gauge, ^spec, 42}
  end

  test "set_to_current_time/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.set_to_current_time(values)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:set_to_current_time, Extatus.Sandbox.Gauge, ^spec, time}
    assert is_integer(time)
  end

  test "track_inprogress/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.track_inprogress(values, fn -> 42 end)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:track_inprogress, Extatus.Sandbox.Gauge, ^spec, 42}
  end

  test "set_duration/1" do
    Metric.subscribe(self())
    values = [label: "Label"]
    GaugeTest.set_duration(values, fn -> 42 end)
    spec = [
      name: @metric,
      labels: ["Label"],
      registry: :default,
    ]
    assert_receive {:set_duration, Extatus.Sandbox.Gauge, ^spec, time}
    assert is_integer(time)
  end
end
