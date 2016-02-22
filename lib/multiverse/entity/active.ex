defmodule Multiverse.Entity.Active do
  use ExActor.GenServer
  use Supervisor
  require Logger

  def init(module, server_pid, entity, state) do
    Logger.info "Starting active trait #{module}..."
    Logger.info "Entity active trait: #{inspect(entity)}"
    entities_sup_list = GameServer.lookup(server_pid, :active_entities_sup)
    entity_module = Entity.get_module(entity)
    entity_sup_pid = entities_sup_list[entity_module]

    child_spec = worker(module, [module, state, entity],
                  function: :start_active_trait, restart: :temporary)
    Supervisor.start_child(entity_sup_pid, child_spec)
  end
end
