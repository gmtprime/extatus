defmodule Extatus.Server do
  @moduledoc """
  Cowboy server to handle Prometheus requests. The default port is 4000. To
  change it just set it in the configuration as:

      config :extatus,
        port: 1337
  """
  alias Extatus.CowboyExporter

  @port Application.get_env(:extatus, :port, 4000)

  @doc """
  Starts the cowboy server with some `options`.
  """
  def start_link(options \\ []) do
    CowboyExporter.setup()
    tcp_opts = [port: @port]
    config = [dispatch: build_config()]
    options =
      options
      |> Keyword.put_new(:env, config)
      |> Keyword.put_new(:compress, true)
    :cowboy.start_http(:http, 100, tcp_opts, options)
  end

  #########
  # Helpers

  @doc false
  def build_config do
    :cowboy_router.compile([
      {:_, [{"/metrics", Extatus.Callback, []}]}
    ])
  end
end
