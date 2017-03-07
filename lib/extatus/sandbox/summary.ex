defmodule Extatus.Sandbox.Summary do
  @moduledoc """
  This module defines a sandbox for testing Prometheus summary calls without a
  prometheus server.
  """
  alias Extatus.Sandbox.Metric

  @doc false
  def new(spec) do
    Metric.new(__MODULE__, spec)
  end

  @doc false
  def declare(spec) do
    Metric.declare(__MODULE__, spec)
  end

  @doc false
  def observe(spec, amount \\ 1) do
    Metric.observe(__MODULE__, spec, amount)
  end

  @doc false
  def dobserve(spec, amount \\ 1) do
    Metric.dobserve(__MODULE__, spec, amount)
  end

  @doc false
  def observe_duration(spec, function) do
    Metric.observe_duration(__MODULE__, spec, function)
  end

  @doc false
  def remove(spec) do
    Metric.remove(__MODULE__, spec)
  end

  @doc false
  def reset(spec) do
    Metric.reset(__MODULE__, spec)
  end

  @doc false
  def value(spec) do
    Metric.value(__MODULE__, spec)
  end
end
