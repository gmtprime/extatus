defmodule Extatus.Server do
  @moduledoc """
  Cowboy server to handle Prometheus requests. The default port is 4000. To
  change it just set it in the configuration as:

      config :extatus,
        port: 1337
  """
  alias Extatus.CowboyExporter
  alias Extatus.Settings

  @doc """
  Starts the cowboy server with some `options`.
  """
  def start_link(options \\ []) do
    port = Settings.extatus_port()
    CowboyExporter.setup()
    options =
      options
      |> Keyword.put_new(:env, %{dispatch: build_config()})
      |> Keyword.put_new(:compress, true)
      |> Enum.into(%{})
    :cowboy.start_clear(:http, [port: port], options)
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
