defmodule Extatus.Metric.Counter do
  @moduledoc """
  This module defines a wrapper over `Prometheus.Metric.Counter` functions to
  be compatible with `Extatus` way of handling metrics.
  """
  alias Extatus.Settings

  @metric Settings.extatus_counter_mod()

  @doc """
  Creates a counter using the `name` of a metric.
  """
  defmacro new(name) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Counter
      name = unquote(name)
      case unquote(caller).get_spec(name) do
        {unquote(module), spec} ->
          unquote(metric).new(spec)
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Creates a counter using the `name` of a `metric`. If the counter exists,
  returns false.
  """
  defmacro declare(name) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Counter
      name = unquote(name)
      case unquote(caller).get_spec(name) do
        {unquote(module), spec} ->
          unquote(metric).declare(spec)
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Increments the counter identified by `name` and `values` (keyword list with
  the correspondence between labels and values) by `value`.
  """
  defmacro inc(name, values, value \\ 1) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Counter
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).inc(spec, unquote(value))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Increments the counter identified by `name` and `values` (keyword list with
  the correspondence between labels and values) by `value`. If `value` happened
  to be a float even one time(!) you shouldn't use `inc/3` after `dinc/3`.
  """
  defmacro dinc(name, values, value \\ 1) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Counter
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).dinc(spec, unquote(value))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Removes counter series identified by `name` and `values` (keyword list with
  the correspondence between labels and values).
  """
  defmacro remove(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Counter
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).remove(spec)
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Resets the value of the counter identified by `name` and `values`
  (keyword list with the correspondence between labels and values).
  """
  defmacro reset(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Counter
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).reset(spec)
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Returns the value of the counter identified by `name` and `values`
  (keyword list with the correspondence between labels and values).
  """
  defmacro value(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Counter
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).value(spec)
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end
end
