defmodule Extatus.Sandbox.Gauge do
  @moduledoc """
  This module defines a sandbox for testing Prometheus gauge calls without a
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
  def set(spec, value) do
    Metric.set(__MODULE__, spec, value)
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
  def dec(spec, value \\ 1) do
    Metric.dec(__MODULE__, spec, value)
  end

  @doc false
  def ddec(spec, value \\ 1) do
    Metric.ddec(__MODULE__, spec, value)
  end

  @doc false
  def set_to_current_time(spec) do
    Metric.set_to_current_time(__MODULE__, spec)
  end

  @doc false
  def track_inprogress(spec, function) do
    Metric.track_inprogress(__MODULE__, spec, function)
  end

  @doc false
  def set_duration(spec, function) do
    Metric.set_duration(__MODULE__, spec, function)
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
