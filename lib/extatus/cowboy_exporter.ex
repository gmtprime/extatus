defmodule Extatus.CowboyExporter do
  @moduledoc """
  Exports the cowboy metrics for the scrape.
  """
  use Extatus.Metric

  @prometheus_registry Application.get_env(:extatus, :prometheus_registry, :default)

  @duration_metric :telemetry_scrape_duration_seconds
  @size_metric :telemetry_scrape_size_bytes

  defmetrics do
    summary @duration_metric do
      label :registry
      label :content_type
      help "Scrape duration"
      registry @prometheus_registry
    end

    summary @size_metric do
      label :registry
      label :content_type
      help "Scrape size uncompressed"
      registry @prometheus_registry
    end
  end

  @doc """
  Scrapes the metrics and does a summary of the requests to the cowboy server.
  """
  def scrape(request) do
    {content_type, format} = negotiate(request)
    
    values = [registry: @prometheus_registry, content_type: content_type]

    # Duration metric
    scrape =
      Summary.observe_duration(@duration_metric, values, fn ->
        format.format(@prometheus_registry)
      end)
    
    # Size metric
    Summary.observe(@size_metric, values, :erlang.iolist_size(scrape))

    {content_type, scrape}
  end

  #########
  # Helpers

  @doc false
  def negotiate(request) do
    try do
      {accept, _request} = :cowboy_req.header("accept", request)
      format = :accept_header.negotiate(accept, [
        {:prometheus_text_format.content_type, :prometheus_text_format},
        {:prometheus_protobuf_format.content_type, :prometheus_protobuf_format}
      ])
      {format.content_type, format}
    rescue
      ErlangError ->
        {:prometheus_text_format.content_type(), :prometheus_text_format}
    end
  end
end
