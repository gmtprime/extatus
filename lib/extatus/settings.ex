defmodule Extatus.Settings do
  @moduledoc """
  Settings for `Extatus`.
  """
  use Skogsra

  @doc """
  Handler timeout. Defaults to `1000` ms.

  Set it in the configuration as follows:
  ```
  config :extatus,
    timeout: 1000
  ```
  """
  app_env :extatus_handler_timeout, :extatus, :timeout, default: 1000

  @doc """
  Metrics HTTP port. Defaults to `4000`.

  Set it in the configuration as follows:
  ```
  config :extatus,
    port: 4000
  ```
  """
  app_env :extatus_port, :extatus, :port, default: 4000

  @doc """
  Prometheus registry. Defaults to `:default`.

  Set it in the configuration as follows:
  ```
  config :extatus,
    prometheus_registry: :default
  ```
  """
  app_env :extatus_prometheus_registry, :extatus, :prometheus_registry,
    default: :default

  @doc """
  Counter module. Defaults to `Prometheus.Metric.Counter`.

  Set it in the configuration as follows:
  ```
  config :extatus,
    counter_mod: Prometheus.Metric.Counter
  ```
  """
  app_env :extatus_counter_mod, :extatus, :counter_mod,
    default: Prometheus.Metric.Counter

  @doc """
  Gauge module. Defaults to `Prometheus.Metric.Gauge`.

  Set it in the configuration as follows:
  ```
  config :extatus,
    gauge_mod: Prometheus.Metric.Gauge
  ```
  """
  app_env :extatus_gauge_mod, :extatus, :gauge_mod,
    default: Prometheus.Metric.Gauge

  @doc """
  Histogram module. Defaults to `Prometheus.Metric.Histogram`.

  Set it in the configuration as follows:
  ```
  config :extatus,
    histogram_mod: Prometheus.Metric.Histogram
  ```
  """
  app_env :extatus_histogram_mod, :extatus, :histogram_mod,
    default: Prometheus.Metric.Histogram

  @doc """
  Summary module. Defaults to `Prometheus.Metric.Summary`.

  Set it in the configuration as follows:
  ```
  config :extatus,
    summary_mod: Prometheus.Metric.Summary
  ```
  """
  app_env :extatus_summary_mod, :extatus, :summary_mod,
    default: Prometheus.Metric.Summary
end
