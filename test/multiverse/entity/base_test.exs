defmodule MultiverseEntityBaseTest do
  use ExUnit.Case
  alias Multiverse.Entity.Base, as: Entity

  setup do
    module = Multiverse
    :ok = Entity.preinit(module)
    {:ok, [module: module]}
  end

  test "preinits ets tables", context do
    info = :ets.info(:"elixir.multiverse")
    assert info[:read_concurrency] == true
  end

  test "initializes an entity module with config data", context do
    {:ok, entity} = Entity.init(context[:module], %{key: "value"})
    assert Entity.base_get(entity, :key) == "value"
  end

  test "sets and gets a key", context do
    {:ok, entity} = Entity.init(context[:module], %{})
    Entity.base_set(entity, %{key: "value"})

    assert "value" == Entity.base_get(entity, :key)
  end

  test "get_module", context do
    {:ok, entity} = Entity.init(context[:module], %{key: "value"})
    assert context[:module] == Entity.get_module(entity)
  end
end
