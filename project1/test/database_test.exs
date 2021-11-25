defmodule DatabaseTest do
  use ExUnit.Case, async: true

  setup do
    pid = start_supervised!(Database)
    %{pid: pid}
  end

  test "Created Empty", %{pid: pid} do
    IO.inspect(pid)
    assert :ok == Database.insert(pid,"key","withValue")
    IO.puts("OK")
    #assert :ok == Database.delete(pid,"key")
    #assert :ok == Database.delete(pid,"notexi")
    assert []  == Database.getallkeys(pid)
  end
end
