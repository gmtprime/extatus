defmodule Extatus.Mixfile do
  use Mix.Project

  @version "0.2.0"

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
     {:cowboy, "~> 1.1"},
     {:prometheus_ex, "~> 1.0"},
     {:accept, "~> 0.1"},
     {:yggdrasil, "~> 3.0"},
     {:earmark, ">= 0.0.0", only: :dev},
     {:ex_doc, "~> 0.13", only: :dev},
     {:uuid, "~> 1.1", only: [:dev, :test]},
     {:inch_ex, "~> 0.5", only: [:dev, :test]},
     {:credo, "~> 0.6", only: [:dev, :test]}]
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
