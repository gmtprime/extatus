defmodule Extatus.Sandbox.Summary do
  @moduledoc """
  This module defines a sandbox for testing Prometheus summary calls without a
  prometheus server.
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

  @doc false
  def observe_duration(spec, f) do
    Metric.observe_duration(__MODULE__, spec, f)
  end
end
