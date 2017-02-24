use Mix.Config

config :extatus,
  counter_mod: Extatus.Sandbox.Counter,
  gauge_mod: Extatus.Sandbox.Gauge,
  histogram_mod: Extatus.Sandbox.Histogram,
  summary_mod: Extatus.Sandbox.Summary,
  timeout: 100
