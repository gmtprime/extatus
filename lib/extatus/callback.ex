defmodule Extatus.Callback do
  @moduledoc """
  This module implements the `/metrics` callback for Prometheus.
  """
  @behaviour :cowboy_handler

  alias Extatus.CowboyExporter

  @doc false
  def init(request, state) do
    method = :cowboy_req.method(request)
    handle(method, request, state)
  end

  @doc false
  def handle("GET", request, state) do
    request = gen_response(request)
    {:ok, request, state}
  end
  def handle(_method, request, state) do
    {:ok, request, state}
  end

  #########
  # Helpers

  @doc false
  def gen_response(request) do
    {content_type, data} = CowboyExporter.scrape(request)
    headers = %{"content-type" => content_type}
    :cowboy_req.reply(200, headers, data, request)
  end
end
