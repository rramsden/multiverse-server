defmodule MultiverseTest do
  use ExUnit.Case
  doctest Multiverse

  test "returns the current version number" do
    version = Multiverse.version
    assert "#{version[:major]}.#{version[:minor]}.#{version[:patch]}" == Multiverse.Mixfile.project[:version]
  end
end
