defmodule Extatus.Sandbox.Gauge do
  @moduledoc """
  This module defines a sandbox for testing Prometheus gauge calls without a
  prometheus server.
  """
  alias Extatus.Sandbox.Metric

  @doc false
  def declare(spec) do
    Metric.declare(__MODULE__, spec)
  end

  @doc false
  def set(spec, value) do
    Metric.set(__MODULE__, spec, value)
  end
end
