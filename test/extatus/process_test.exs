defmodule Extatus.ProcessTest do
  use ExUnit.Case, async: true

  defmodule TestProcess do
    use Extatus.Process
  end

  test "default get name" do
    name = inspect(:erlang.phash2(:name))
    assert {:ok, ^name} = TestProcess.get_name(:name)
  end

  test "default report" do
    assert :ok = TestProcess.report(:state)
  end

  test "watchdog function exists" do
    assert Keyword.has_key?(
      TestProcess.__info__(:functions),
      :add_extatus_watchdog
    )
  end
end
