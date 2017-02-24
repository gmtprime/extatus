defmodule Extatus.ProcessTest do
  use ExUnit.Case, async: true

  defmodule TestProcess do
    use Extatus.Process
  end

  test "not implemented" do
    assert {:error, _} = TestProcess.get_name(:name)
    assert {:error, _} = TestProcess.report(:state)
  end
end
