defmodule Extatus.Metric.Gauge do
  @moduledoc """
  This module defines a wrapper over `Prometheus.Metric.Gauge` functions to
  be compatible with `Extatus` way of handling metrics.
  """
  @metric Application.get_env(:extatus, :gauge_mod, Prometheus.Metric.Gauge)

  @doc """
  Creates a gauge using the `name` of a metric.
  """
  defmacro new(name) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
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
  Creates a gauge using the `name` of a `metric`. If the counter exists,
  returns false.
  """
  defmacro declare(name) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
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
  Increments the gauge identified by `name` and `values` (keyword list with
  the correspondence between labels and values) by `value`.
  """
  defmacro inc(name, values, value \\ 1) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
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
  Increments the gauge identified by `name` and `values` (keyword list with
  the correspondence between labels and values) by `value`. If `value` happened
  to be a float even one time(!) you shouldn't use `inc/3` after `dinc/3`.
  """
  defmacro dinc(name, values, value \\ 1) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
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
  Decrements the gauge identified by `name` and `values` (keyword list with
  the correspondence between labels and values) by `value`.
  """
  defmacro dec(name, values, value \\ 1) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).dec(spec, unquote(value))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Decrements the gauge identified by `name` and `values` (keyword list with
  the correspondence between labels and values) by `value`. If `value` happened
  to be a float even one time(!) you shouldn't use `dec/3` after `ddec/3`.
  """
  defmacro ddec(name, values, value \\ 1) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).ddec(spec, unquote(value))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Sets the gauge identified by `name` and `values` (keyword list with the
  correspondence between labels and values) by `value`.
  """
  defmacro set(name, values, value) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).set(spec, unquote(value))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Sets the gauge identified by `name` and `values` (keyword list with the
  correspondence between labels and values) to the current unix time.
  """
  defmacro set_to_current_time(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).set_to_current_time(spec)
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Sets the gauge identified by `name` and `values` (keyword list with the
  correspondence between labels and values) to the number of the currently
  executing `function`.
  """
  defmacro track_inprogress(name, values, function) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).track_inprogress(spec, unquote(function))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Sets the gauge identified by `name` and `values` (keyword list with the
  correspondence between labels and values) to the amount of time spent
  executing `function`.
  """
  defmacro set_duration(name, values, function) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
      name = unquote(name)
      case unquote(caller).gen_spec(name, unquote(values)) do
        {unquote(module), spec} ->
          unquote(metric).set_duration(spec, unquote(function))
        _ ->
          raise %Prometheus.UnknownMetricError{registry: nil, name: name}
      end
    end
  end

  @doc """
  Removes gauge series identified by `name` and `values` (keyword list with
  the correspondence between labels and values).
  """
  defmacro remove(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
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
  Resets the value of the gauge identified by `name` and `values`
  (keyword list with the correspondence between labels and values).
  """
  defmacro reset(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
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
  Returns the value of the gauge identified by `name` and `values`
  (keyword list with the correspondence between labels and values).
  """
  defmacro value(name, values) do
    module = __MODULE__
    caller = __CALLER__.module()
    metric = @metric
    quote do
      require Prometheus.Metric.Gauge
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
