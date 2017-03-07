defmodule Extatus.Sandbox.Counter do
  @moduledoc """
  This module defines a sandbox for testing Prometheus counter calls without a
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
  def inc(spec, value \\ 1) do
    Metric.inc(__MODULE__, spec, value)
  end

  @doc false
  def dinc(spec, value \\ 1) do
    Metric.dinc(__MODULE__, spec, value)
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
