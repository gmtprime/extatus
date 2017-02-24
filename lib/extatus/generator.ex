defmodule Extatus.Generator do
  @moduledoc """
  This module implements a handler generator. It generates handlers on demand.
  """
  use Supervisor

  @handler Extatus.Handler
  @registry Application.get_env(:extatus, :registry, ExReg)

  @doc """
  Starts a generator with some optional `Supervisor` `options`
  """
  @spec start_link() :: Supervisor.on_start
  @spec start_link(Supervisor.options) :: Supervisor.on_start
  def start_link(options \\ []) do
    Supervisor.start_link(__MODULE__, nil, options)
  end

  @doc """
  Stops a `generator`.
  """
  @spec stop(Supervisor.name) :: :ok
  def stop(generator) do
    Supervisor.stop(generator)
  end

  @doc """
  Generates a new handler with the process `pid` to monitor it using a
  `generator` name or PID.
  """
  @spec start_handler(Supervisor.name, module, pid) :: Supervisor.on_start_child
  def start_handler(generator, module, pid) do
    name = {@handler, pid}
    case @registry.whereis_name(name) do
      :undefined ->
        via_tuple = {:via, @registry, name}
        Supervisor.start_child(generator, [module, pid, [name: via_tuple]])
      handler ->
        {:ok, handler}
    end
  end

  @doc """
  Stops a handler with the process `pid` of the monitored process with an
  optional `reason`.
  """
  @spec stop_handler(pid) :: :ok
  @spec stop_handler(pid, term) :: :ok
  def stop_handler(pid, reason \\ :normal) do
    name = {@handler, pid}
    case @registry.whereis_name(name) do
      :undefined ->
        :ok
      handler ->
        @handler.stop(handler, reason)
    end
  end

  #####################
  # Supervisor callback

  @doc false
  def init(_) do
    import Supervisor.Spec

    children = [
      supervisor(@handler, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
