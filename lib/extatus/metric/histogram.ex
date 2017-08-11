defmodule Extatus.Metric.Histogram do
  @moduledoc """
  This module defines a wrapper over `Prometheus.Metric.Histogram` functions to
  be compatible with `Extatus` way of handling metrics.
  """
  alias Extatus.Settings

  @metric Settings.extatus_histogram_mod()

  @doc """
  Creates a histogram using the `name` of a metric.
  """
  defmacro new(name) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Histogram
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
  Creates a histogram using the `name` of a `metric`. If the counter exists,
  returns false.
  """
  defmacro declare(name) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Histogram
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
  Observes the given `amount` for the histogram identified by `name` and
  `values` (keyword list with the correspondence between labels and values).
  """
  defmacro observe(name, values, amount \\ 1) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Histogram
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).observe(spec, unquote(amount))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Observes the given `amount` for the histogram identified by `name` and
  `values` (keyword list with the correspondence between labels and values). If
  `amount` happened to be a float number even one time(!) you shoudn't use
  `observe/3` after `dobserve/3`.
  """
  defmacro dobserve(name, values, amount \\ 1) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Histogram
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).dobserve(spec, unquote(amount))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Observes the histogram identified by `name` and `values` (keyword list with
  the correspondence between labels and values) to the amount of time spent
  executing `function`.
  """
  defmacro observe_duration(name, values, function) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Histogram
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).observe_duration(spec, unquote(function))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Removes histogram series identified by `name` and `values` (keyword list with
  the correspondence between labels and values).
  """
  defmacro remove(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Histogram
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
  Resets the value of the histogram identified by `name` and `values`
  (keyword list with the correspondence between labels and values).
  """
  defmacro reset(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Histogram
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
  Returns the value of the histogram identified by `name` and `values`
  (keyword list with the correspondence between labels and values).
  """
  defmacro value(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Histogram
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
