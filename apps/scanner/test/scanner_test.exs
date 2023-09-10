defmodule ScannerTest do
  use ExUnit.Case
  doctest Scanner

  test "greets the world" do
    assert Scanner.hello() == :world
  end
end
