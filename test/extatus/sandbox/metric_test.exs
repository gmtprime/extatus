defmodule Extatus.Sandbox.MetricTest do
  use ExUnit.Case, async: true

  alias Extatus.Sandbox.Metric

  test "subscribe/1" do
    assert :ok = Metric.subscribe(self())
    %{subscribers: subscribers} = :sys.get_state(Metric)
    receivers = Map.get(subscribers, self())
    assert Enum.member?(receivers, self())
  end

  test "gen_data/1 with no value" do
    pid = self()
    spec = [name: UUID.uuid4(), labels: [:foo, :bar, :baz]]
    assert {^pid, Module, ^spec, nil} = Metric.gen_data(Module, spec)
  end

  test "gen_data/1 with value" do
    pid = self()
    spec = [name: UUID.uuid4(), labels: [:foo, :bar, :baz]]
    assert {^pid, Module, ^spec, 42} = Metric.gen_data(Module, spec, 42)
  end

  test "send_data/2" do
    assert :ok = Metric.subscribe(self())
    spec = [name: UUID.uuid4(), labels: [:foo, :bar, :baz]]
    data = Metric.gen_data(Module, spec, 42)
    Metric.send_data(:function, data)
    assert_receive {:function, Module, ^spec, 42}
  end
end
