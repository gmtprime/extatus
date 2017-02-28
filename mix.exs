defmodule Extatus.Mixfile do
  use Mix.Project

  def project do
    [app: :extatus,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :prometheus_ex, :cowboy],
     mod: {Extatus, []}]
  end

  defp deps do
    [{:exreg, "~> 0.0"},
     {:cowboy, "~> 1.1"},
     {:prometheus_ex, "~> 1.0"},
     {:accept, "~> 0.1"},
     {:uuid, "~> 1.1", only: [:dev, :test]},
     {:inch_ex, "~> 0.5", only: [:dev, :test]},
     {:credo, "~> 0.6", only: [:dev, :test]}]
  end
end
