defmodule Extatus.Metric do
  @moduledoc """
  This module defines several macros to be able to generate metrics for
  Prometheus i.e:

      defmodule TestMetrics do
        use Extatus.Metric

        defmetrics do
          counter :counter_test do
            label :id
            label :something
            registry :default
            help "Counter test"
          end
        end
      end

  After that one can use the function `TestMetrics.setup/0` to declare the
  metrics at runtime and the `TestMetrics.gen_spec/2` to generate the
  specs of an actual obsevation i.e:

      iex> TestMetrics.setup()
      :ok
      iex> labels = [something: "Something", id: 1]
      [something: "Something", id: 1]
      iex> {Prometheus.Metric.Counter, spec} = TestMetrics.gen_spec(:counter_test, labels)
      {Prometheus.Metric.Counter, [name: :counter_test, labels: ["1", "Something"]}
      iex> require Prometheus.Metric.Counter
      Prometheus.Metric.Counter
      iex> Prometheus.Metric.Counter.inc(spec)
      :ok

  The module `Extatus.Process` uses this module.

  To change the default registry, just change the configuration i.e:

      config :extatus,
        prometheus_registry: "default"
  """
  use Prometheus.Metric

  @doc """
  Adds the functions `setup/0` and `gen_spec/2` for metric declaration.
  """
  defmacro __using__(_) do
    quote do
      import Extatus.Metric
      alias Extatus.Metric
      use Prometheus.Metric

      @counter_mod Application.get_env(:extatus, :counter_mod, Counter)
      @gauge_mod Application.get_env(:extatus, :gauge_mod, Gauge)
      @histogram_mod Application.get_env(:extatus, :histogram_mod, Histogram)
      @summary_mod Application.get_env(:extatus, :summary_mod, Summary)
      @prometheus_registry Application.get_env(:extatus, :prometheus_registry, "default")

      @doc false
      def __metrics__, do: %{}

      @doc false
      def setup do
        metrics = __metrics__()
        for {_, {module, spec}} <- metrics do
          case module do
            Counter -> @counter_mod.declare(spec)
            Gauge -> @gauge_mod.declare(spec)
            Histogram -> @histogram_mod.declare(spec)
            Summary -> @summary_mod.declare(spec)
          end
        end
        :ok
      end

      @doc false
      def gen_spec(name, labels \\ []) do
        metrics = __metrics__()
        with {module, spec} <- metrics[name] do
          registry = Keyword.get(spec, :registry, @prometheus_registry)
          keys = Keyword.get(spec, :labels, [])
          values =
            for key <- keys do
              value = Keyword.get(labels, key)
              if not is_binary(value), do: inspect(value), else: value
            end
          {module, [name: name, labels: values, registry: registry]}
        else
          _ -> :error
        end
      end

      defoverridable [__metrics__: 0]
    end
  end

  @doc """
  Macro to define metrics in the current module i.e:

      defmetrics do
        counter :counter_test do
          label :label
          registry :default
          help "Counter test"
        end
      end

  Every metric in a module should be declared inside this macro.
  """
  defmacro defmetrics(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :extatus_metrics, accumulate: true)
      unquote(block)
      Module.eval_quoted(__ENV__, [Extatus.Metric.__metrics__(@extatus_metrics)])
    end
  end

  @doc """
  Receives the `name` of the counter metric and the definition `block`. Accepts
  the `label/1`, `registry/1` and the `help/1` declarations i.e.

      defmetrics do
        counter :counter_test do
          label :label
          registry :default
          help "Counter test"
        end
      end
  """
  defmacro counter(name, do: block) do
    spec = expand(:counter, block, [name: name])
    type = Prometheus.Metric.Counter
    quote do
      Extatus.Metric.__metric__(
        __MODULE__,
        unquote(type),
        unquote(name),
        unquote(spec)
      )
    end
  end

  @doc """
  Receives the `name` of the gauge metric and the definition `block`. Accepts
  the `label/1`, `registry/1` and the `help/1` declarations.

      defmetrics do
        gauge :gauge_test do
          label :label
          registry :default
          help "Gauge test"
        end
      end
  """
  defmacro gauge(name, do: block) do
    spec = expand(:gauge, block, [name: name])
    type = Prometheus.Metric.Gauge
    quote do
      Extatus.Metric.__metric__(
        __MODULE__,
        unquote(type),
        unquote(name),
        unquote(spec)
      )
    end
  end

  @doc """
  Receives the `name` of the histogram metric and the definition `block`.
  Accepts the `label/1`, `registry/1`, `buckets/1` and the `help/1`
  declarations.

      defmetrics do
        counter :histogram_test do
          label :label
          registry :default
          help "Histogram test"
          buckets {:linear, 0, 1_000_000, 100_000}
        end
      end

  See `Prometheus.Metric.Histogram` for buckets definitions.
  """
  defmacro histogram(name, do: block) do
    spec = expand(:histogram, block, [name: name])
    type = Prometheus.Metric.Histogram
    quote do
      Extatus.Metric.__metric__(
        __MODULE__,
        unquote(type),
        unquote(name),
        unquote(spec)
      )
    end
  end

  @doc """
  Receives the `name` of the summary metric and the definition `block`. Accepts
  the `label/1`, `registry/1` and the `help/1` declarations.

      defmetrics do
        summary :summary_test do
          label :label
          registry :default
          help "Summary test"
        end
      end
  """
  defmacro summary(name, do: block) do
    spec = expand(:summary, block, [name: name])
    type = Prometheus.Metric.Summary
    quote do
      Extatus.Metric.__metric__(
        __MODULE__,
        unquote(type),
        unquote(name),
        unquote(spec)
      )
    end
  end

  #########
  # Helpers

  @doc false
  def expand(type, {:__block__, _, stmts}, spec) do
    Enum.reduce(stmts, spec, &(expand(type, &1, &2)))
  end
  def expand(_type, {:label, _, [name]}, spec) when is_atom(name) do
    {labels, spec} = Keyword.pop(spec, :labels, [])
    Keyword.put_new(spec, :labels, labels ++ [name])
  end
  def expand(_type, {:help, _, [help]}, spec) when is_binary(help) do
    Keyword.put_new(spec, :help, help)
  end
  def expand(_type, {:registry, _, [registry]}, spec)
      when is_binary(registry) or is_atom(registry) do
    Keyword.put_new(spec, :registry, registry)
  end
  def expand(:histogram, {:buckets, _, [buckets]}, spec)
      when is_list(buckets) or buckets == :default do
    Keyword.put_new(spec, :buckets, buckets)
  end
  def expand(:histogram, {:buckets, _, [{:{}, _, [type, _, _, _]} = value]}, spec)
      when type == :linear or type == :exponential do
    value = quote do: unquote(value)
    Keyword.put_new(spec, :buckets, value)
  end
  def expand(_type, _value, state) do
    state
  end

  @doc false
  def __metric__(module, metric, name, spec) do
    Module.put_attribute(module, :extatus_metrics, {name, {metric, spec}})
  end

  @doc false
  def __metrics__(metrics) do
    map = metrics |> Enum.into(%{}) |> Macro.escape()
    quote do
      def __metrics__, do: unquote(map)
    end
  end
end
