defmodule Extatus.MetricTest do
  use ExUnit.Case, async: true

  alias Extatus.Sandbox.Metric

  defmodule TestMetrics do
    use Extatus.Metric

    defmetrics do
      counter :counter_test do
        label :module
        label :name
        registry :default
        help "Test counter"
      end

      gauge :gauge_test do
        label :module
        label :name
        registry :default
        help "Test gauge"
      end

      histogram :histogram_test do
        label :module
        label :name
        registry :default
        help "Test histogram"
        buckets {:linear, 0, 1_000_000, 100_000}
      end

      summary :summary_test do
        label :module
        label :name
        registry :default
        help "Test summary"
      end
    end
  end

  test "Counter metric declaration" do
    assert {Extatus.Metric.Counter, spec} = TestMetrics.get_spec(:counter_test)
    assert spec[:name] == :counter_test
    assert spec[:labels] == [:module, :name]
    assert spec[:registry] == :default
    assert spec[:help] == "Test counter"
  end

  test "Counter metric generation" do
    labels = [name: "Counter", module: Module]
    assert {Extatus.Metric.Counter, spec} = TestMetrics.gen_spec(:counter_test, labels)
    assert spec[:name] == :counter_test
    assert spec[:labels] == ["Module", "Counter"]
  end

  test "Gauge metric declaration" do
    assert {Extatus.Metric.Gauge, spec} = TestMetrics.get_spec(:gauge_test)
    assert spec[:name] == :gauge_test
    assert spec[:labels] == [:module, :name]
    assert spec[:registry] == :default
    assert spec[:help] == "Test gauge"
  end

  test "Gauge metric generation" do
    labels = [name: "Gauge", module: Module]
    assert {Extatus.Metric.Gauge, spec} = TestMetrics.gen_spec(:gauge_test, labels)
    assert spec[:name] == :gauge_test
    assert spec[:labels] == ["Module", "Gauge"]
  end

  test "Histogram metric declaration" do
    assert {Extatus.Metric.Histogram, spec} = TestMetrics.get_spec(:histogram_test)
    assert spec[:name] == :histogram_test
    assert spec[:labels] == [:module, :name]
    assert spec[:registry] == :default
    assert spec[:buckets] == {:linear, 0, 1_000_000, 100_000}
    assert spec[:help] == "Test histogram"
  end

  test "Histogram metric generation" do
    labels = [name: "Histogram", module: Module]
    assert {Extatus.Metric.Histogram, spec} = TestMetrics.gen_spec(:histogram_test, labels)
    assert spec[:name] == :histogram_test
    assert spec[:labels] == ["Module", "Histogram"]
  end

  test "Summary metric declaration" do
    assert {Extatus.Metric.Summary, spec} = TestMetrics.get_spec(:summary_test)
    assert spec[:name] == :summary_test
    assert spec[:labels] == [:module, :name]
    assert spec[:registry] == :default
    assert spec[:help] == "Test summary"
  end

  test "Summary metric generation" do
    labels = [name: "Summary", module: Module]
    assert {Extatus.Metric.Summary, spec} = TestMetrics.gen_spec(:summary_test, labels)
    assert spec[:name] == :summary_test
    assert spec[:labels] == ["Module", "Summary"]
  end

  test "setup/0" do
    pid = self()
    :ok = Metric.subscribe(pid)

    assert :ok = TestMetrics.setup()
    assert_receive {:declare, Extatus.Sandbox.Counter, spec, nil}
    assert spec[:name] == :counter_test
    assert spec[:labels] == [:module, :name]
    assert_receive {:declare, Extatus.Sandbox.Gauge, spec, nil}
    assert spec[:name] == :gauge_test
    assert spec[:labels] == [:module, :name]
    assert_receive {:declare, Extatus.Sandbox.Histogram, spec, nil}
    assert spec[:name] == :histogram_test
    assert spec[:labels] == [:module, :name]
    assert_receive {:declare, Extatus.Sandbox.Summary, spec, nil}
    assert spec[:name] == :summary_test
    assert spec[:labels] == [:module, :name]
  end
end
