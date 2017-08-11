defmodule Extatus.Mixfile do
  use Mix.Project

  @version "0.2.4"

  def project do
    [app: :extatus,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     docs: docs(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :yggdrasil, :prometheus_ex, :cowboy],
     mod: {Extatus, []}]
  end

  defp deps do
    [{:exreg, "~> 0.0"},
     {:skogsra, "~> 0.1"},
     {:cowboy, "~> 1.1"},
     {:prometheus_ex, "~> 1.3"},
     {:accept, "~> 0.3"},
     {:yggdrasil, "~> 3.2"},
     {:ex_doc, "~> 0.16", only: :dev, runtime: false},
     {:uuid, "~> 1.1", only: [:dev, :test]},
     {:inch_ex, "~> 0.5", only: [:dev, :test]},
     {:credo, "~> 0.8", only: [:dev, :test]}]
  end

  defp docs do
    [source_url: "https://github.com/gmtprime/extatus",
     source_ref: "v#{@version}",
     main: Extatus]
  end

  defp description do
    """
    App to report metrics to Prometheus from Elixir GenServers.
    """
  end

  defp package do
    [maintainers: ["Alexander de Sousa"],
     licenses: ["MIT"],
     links: %{"Github" => "https://github.com/gmtprime/extatus"}]
  end
end
