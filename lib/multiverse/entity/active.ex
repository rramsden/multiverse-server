defmodule Multiverse.Entity.Active do
  use ExActor.GenServer
  use Supervisor
  require Logger

  def start_link(module, state, entity) do
    Logger.info "Starting entity process: #{module}"
    initial_state(%{module: module, state: state, entity: entity})
  end

  def init(module, server_pid, entity, state) do
    Logger.info "Starting active trait #{module}..."
    Logger.info "Entity active trait: #{inspect(entity)}"

    entities_sup_list = Service.lookup(server_pid, :entity_sup)
    entity_module = Entity.get_module(entity)
    entity_sup_pid = entities_sup_list[entity_module]

    child_spec = worker(module, [module, state, entity],
                        function: :start_active_trait, restart: :temporary)

    {:ok, pid} = Supervisor.start_child(entity_sup_pid, child_spec)

    Entity.base_set(entity, %{pid: pid})
  end
end
