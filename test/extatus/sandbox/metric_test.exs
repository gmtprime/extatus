defmodule Extatus.Sandbox.MetricTest do
  use ExUnit.Case, async: true

  alias Extatus.Sandbox.Metric

  test "subscribe/1" do
    assert :ok = Metric.subscribe(self())
    %{subscribers: subscribers} = :sys.get_state(Metric)
    receivers = Map.get(subscribers, self())
    assert Enum.member?(receivers, self())
  end

  test "declare/2" do
    name = UUID.uuid4()
    labels = [:foo, :bar, :baz]
    assert :ok = Metric.subscribe(self())
    assert :ok = Metric.declare(Module, [name: name, labels: labels])
    assert_receive {:declare, {_, Module, ^name}, ^labels}
    assert :ok = Metric.declare(Module, [name: name, labels: labels])
    assert_receive {:declare, {_, Module, ^name}, ^labels}
  end

  test "inc/3" do
    name = UUID.uuid4()
    labels = [:foo, :bar, :baz]
    assert :ok = Metric.subscribe(self())
    assert :ok = Metric.declare(Module, [name: name, labels: labels])
    assert_receive {:declare, {_, Module, ^name}, ^labels}

    value = 41
    labels = [UUID.uuid4(), UUID.uuid4(), UUID.uuid4()]
    assert :ok = Metric.inc(Module, [name: name, labels: labels], value)
    assert_receive {:inc, {_, Module, ^name, ^labels}, ^value}
    assert :ok = Metric.inc(Module, [name: name, labels: labels])
    assert_receive {:inc, {_, Module, ^name, ^labels}, 42}
  end

  test "set/3" do
    name = UUID.uuid4()
    labels = [:foo, :bar, :baz]
    assert :ok = Metric.subscribe(self())
    assert :ok = Metric.declare(Module, [name: name, labels: labels])
    assert_receive {:declare, {_, Module, ^name}, ^labels}

    value = 42
    labels = [UUID.uuid4(), UUID.uuid4(), UUID.uuid4()]
    assert :ok = Metric.set(Module, [name: name, labels: labels], value)
    assert_receive {:set, {_, Module, ^name, ^labels}, ^value}
  end

  test "observe/3" do
    name = UUID.uuid4()
    labels = [:foo, :bar, :baz]
    assert :ok = Metric.subscribe(self())
    assert :ok = Metric.declare(Module, [name: name, labels: labels])
    assert_receive {:declare, {_, Module, ^name}, ^labels}

    value = 42
    labels = [UUID.uuid4(), UUID.uuid4(), UUID.uuid4()]
    assert :ok = Metric.observe(Module, [name: name, labels: labels], value)
    assert_receive {:observe, {_, Module, ^name, ^labels}, ^value}
  end
end
