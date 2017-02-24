defmodule Extatus.Sandbox.Counter do
  @moduledoc """
  This module defines a sandbox for testing Prometheus counter calls without a
  prometheus server.
  """
  alias Extatus.Sandbox.Metric

  @doc false
  def declare(spec) do
    Metric.declare(__MODULE__, spec)
  end

  @doc false
  def inc(spec, value \\ 1) do
    Metric.inc(__MODULE__, spec, value)
  end
end
