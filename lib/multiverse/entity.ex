defmodule Multiverse.Entity do
  require Logger

  @moduledoc """
  Behaviour module for creating server entities. This module
  contains functions setting up ETS storage for an entity.
  """

  @type entity :: {Module.t, reference(), node()}

  @callback init(Module.t) :: {:ok, entity()}
  @callback get(entity(), tuple()) :: any()
  @callback set(entity(), any()) :: any()

  @doc """
  Sets up an ETS table for this entity
  """
  @spec preinit(atom()) :: :ok
  def preinit(module) do
    entity = {module, :none, :none}
    table_name = ets_table_name(entity)
    :ets.new(table_name, [:named_table, read_concurrency: true])
    :ok
  end

  def init(module, data) do
    # unique tuple to identify this entity
    entity = {module, make_ref, node}

    # write init data to ETS
    base_set(entity, data)

    # return reference
    {:ok, entity}
  end

  @doc """
  Fetch %key% from ETS storage
  """
  def base_get(entity, key) do
    table_name = ets_table_name(entity)
    ets_key = ets_key_name(entity, key)
    case :ets.lookup(table_name, ets_key) do
      [] -> :not_found
      [{_, value}] -> value
    end
  end

  @doc """
  Store %map% in ETS storage
  """
  def base_set(entity, map) do
    Logger.info "Map #{inspect(map)}"
    table_name = ets_table_name(entity)

    Enum.each(map, fn {key,value} ->
      key = ets_key_name(entity, key)
      :ets.insert(table_name, {key, value})
    end)
  end

  # UTILITY

  @doc """
  Retrieves module name from entity
  """
  @spec get_module(entity()) :: module()
  def get_module({module, _, _}), do: module

  # CALLBACK API

  def get(entity, key) do
    {module, _, _} = entity
    module.get(entity, key)
  end

  def set(entity, key, value) do
    {module, _, _} = entity
    module.set(entity, key, value)
  end

  defp ets_table_name({module, _, _}) do
    to_string(module) |>
      String.downcase |>
      String.to_atom
  end

  defp ets_key_name(entity, key) do
    {module, ref, node} = entity
    :erlang.binary_to_list(:erlang.term_to_binary(ref))
  end
end
