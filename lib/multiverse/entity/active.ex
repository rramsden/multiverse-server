defmodule Multiverse.Entity.Active do
  use ExActor.GenServer
  use Supervisor
  require Logger

  @type entity :: {Module.t, reference(), node()}
  @callback start_active_trait(module(), any(), entity()) :: {:ok, pid()}

  defstart start_link(module, state, entity) do
    Logger.info "Start active entity process: #{module}..."
    initial_state(%{module: module, current_state: state, entity: entity})
  end

  def notify_sync_event(entity, event, message) do
    call(get_pid_from_entity(entity), event, message)
  end

  def notify_event(entity, event, message) do
    cast(get_pid_from_entity(entity), event, message)
  end

  defcallp call(event, message), state: state do
    {:ok, next_state} = apply(state.module, state.current_state, [{event, message}, state.entity])
    set_and_reply(put_in(state.current_state, next_state), next_state)
  end

  defcastp cast(event, message), state: state do
    {:ok, next_state} = apply(state.module, state.current_state, [{event, message}, state.entity])
    new_state(put_in(state.current_state, next_state))
  end

  def init(module, entity, state) do
    Logger.info "Starting active trait #{module}..."
    Logger.info "Entity active trait: #{inspect(entity)}"

    entity_active_sups = Multiverse.Service.lookup(:entity_active_sups)
    supervisor_pid = entity_active_sups[module]
    {:ok, _entity} = start_entity(module, supervisor_pid, entity, state)
  end

  def start_entity(module, supervisor_pid, entity, state) do
    child_spec = {make_ref, {module, :start_active_trait, [module, state, entity]}, :temporary, 2000, :worker, [module]}
    {:ok, pid} = Supervisor.start_child(supervisor_pid, child_spec)
    entity = Multiverse.Entity.base_set(entity, trait_active_pid: pid)
    {:ok, entity}
  end

  defp get_pid_from_entity(entity) do
    Multiverse.Entity.base_get(entity, :trait_active_pid)
  end
end
