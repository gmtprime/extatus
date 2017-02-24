defmodule Extatus.Callback do
  @moduledoc """
  This module implements the `/metrics` callback for Prometheus.
  """
  alias Extatus.CowboyExporter

  @doc false
  def init(_transport, request, _opts), do: {:ok, request, nil}

  @doc false
  def handle(request, state) do
    {method, request} = :cowboy_req.method(request)
    handle(method, request, state)
  end

  @doc false
  def terminate(_reason, _request, _state), do: :ok

  #########
  # Helpers

  @doc false
  def handle("GET", request, state) do
    {:ok, request} = gen_response(request)
    {:ok, request, state}
  end
  def handle(_method, request, state) do
    {:ok, request, state}
  end

  @doc false
  def gen_response(request) do
    {content_type, data} = CowboyExporter.scrape(request)
    headers = [{"content-type", content_type}]
    :cowboy_req.reply(200, headers, data, request)
  end
end
