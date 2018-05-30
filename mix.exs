defmodule Extatus.Mixfile do
  use Mix.Project

  @version "0.2.5"

  def project do
    [app: :extatus,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     docs: docs(),
     deps: deps()]
  end

  def application do
    [applications: [:lager, :logger, :yggdrasil, :prometheus_ex, :cowboy],
     mod: {Extatus, []}]
  end

  defp deps do
    [{:yggdrasil, "~> 3.3"},
     {:skogsra, "~> 0.2"},
     {:cowboy, "~> 2.3"},
     {:prometheus_ex, "~> 3.0"},
     {:accept, "~> 0.3"},
     {:ex_doc, "~> 0.18", only: :dev},
     {:uuid, "~> 1.1", only: [:dev, :test]},
     {:credo, "~> 0.9", only: [:dev, :test]}]
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
