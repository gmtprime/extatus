defmodule Extatus.Sandbox.Histogram do
  @moduledoc """
  This module defines a sandbox for testing Prometheus histogram calls without
  a prometheus server.
  """
  alias Extatus.Sandbox.Metric

  @doc false
  def declare(spec) do
    Metric.declare(__MODULE__, spec)
  end

  @doc false
  def observe(spec, amount \\ 1) do
    Metric.observe(__MODULE__, spec, amount)
  end
end
