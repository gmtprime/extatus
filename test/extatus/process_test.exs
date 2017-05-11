defmodule Extatus.ProcessTest do
  use ExUnit.Case, async: true

  defmodule TestProcess do
    use Extatus.Process
  end

  test "not implemented" do
    name = inspect(:erlang.phash2(:name))
    assert {:ok, ^name} = TestProcess.get_name(:name)
    assert :ok = TestProcess.report(:state)
  end
end
