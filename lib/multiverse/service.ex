defmodule Multiverse.Service do
  use Supervisor
  require Logger

  @table_name :multiverse

  @moduledoc """
  Main service module for Multiverse
  """

  def start_link(config) do
    Logger.info "Starting Multiverse..."
    {:ok, pid} = Supervisor.start_link(__MODULE__, config, name: __MODULE__)
    :ok = start(config)
    {:ok, pid}
  end

  def init(config) do
    entities = config[:entities]
    preinit_entities(entities)
    supervise([], strategy: :one_for_one)
  end

  def lookup(key) do
    case :ets.lookup(@table_name, key) do
      [] -> :not_found
      [{_, value}] -> value
    end
  end

  def start(config) do
    # Start multiverse supervisors
    {:ok, session_sup} = start_supervisor(Multiverse.SessionSupervisor)
    {:ok, entity_sup} = start_supervisor(Multiverse.Entity.Supervisor)

    state = [
      {:session_sup, session_sup},
      {:entity_sup, entity_sup}
    ]
    save(state)
    :ok
  end

  defp save(state) do
    :ets.new(@table_name, [:set, :named_table, :public])
    :ets.insert(@table_name, state)
  end

  defp start_supervisor(module) do
    child_spec = supervisor(module, [], restart: :permanent, modules: :dynamic)
    Supervisor.start_child(__MODULE__, child_spec)
  end

  defp preinit_entities(entities) do
    Enum.each entities, &Multiverse.Entity.preinit(&1)
  end
end
