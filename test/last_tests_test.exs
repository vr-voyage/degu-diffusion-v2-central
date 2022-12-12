defmodule LastTestsTest do
  use ExUnit.Case
  doctest LastTests

  test "greets the world" do
    assert LastTests.hello() == :world
  end
end
