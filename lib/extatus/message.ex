defmodule Extatus.Message do
  @moduledoc """
  Message sent by Extatus on supervised process state update.
  """
  defstruct [:name, :state]

  @typedoc "Process state"
  @type state :: :up | :down | :idle

  @typedoc "Extatus message"
  @type t :: %__MODULE__{name: name :: binary, state: state :: state}
end
