defmodule Multiverse.Entity.Active do
  @behaviour :gen_fsm

  use Supervisor
  require Logger

  @type entity :: {Module.t, reference(), node()}
  @callback start_active_trait(module(), any(), entity()) :: {:ok, pid()}

  def start_active_trait(module, initial_state, entity) do
    Logger.info "Starting active trait gen_fsm: #{module}..."
    :gen_fsm.start_link(__MODULE__, {module, initial_state, entity}, [])
  end

  def init(module, entity, state) do
    Logger.info "Starting active trait #{module}..."
    Logger.info "Entity active trait: #{inspect(entity)}"

    entity_active_sups = Multiverse.Service.lookup(:entity_active_sups)
    supervisor_pid = entity_active_sups[module]
    {:ok, _pid} = start_entity(module, supervisor_pid, entity, state)
  end

  def start_entity(module, supervisor_pid, entity, initial_state) do
    child_spec = {make_ref, {module, :start_active_trait, [module, initial_state, entity]}, :temporary, 2000, :worker, [module]}
    {:ok, pid} = Supervisor.start_child(supervisor_pid, child_spec)
    entity = Multiverse.Entity.base_set(entity, %{trait_active_pid: pid})
    {:ok, entity}
  end

  defp get_pid_from_entity(entity) do
    Multiverse.Entity.base_get(entity, :trait_active_id)
  end

  # ---------- GEN_FSM API ----------- #

  def notify_sync_event(entity, event, message) do
    :gen_fsm.sync_send_event(get_pid_from_entity(entity), {event, message})
  end

  def notify_event(entity, event, message) do
    :gen_fsm.sync_event(get_pid_from_entity(entity), {event, message})
  end

  # async
  def running({event, message}, {module, state, data}) do
    response = apply(module, state, [{event, message}, data])
    case response do
      {:next_state, new_state, new_data}             -> {:next_state, :running, {module, new_state, new_data}}
      {:next_state, new_state, new_data, :hibernate} -> {:next_state, :running, {module, new_state, new_data}, :hibernate}
      {:next_state, new_state, new_data, timeout}    -> {:next_state, :running, {module, new_state, new_data}, timeout}
      {:stop, reason, new_data}                      -> {:stop, reason, {module, :stopped, new_data}}
    end
  end

  # sync
  def running({event, message}, _from, {module, state, data}) do
    response = apply(module, state, [{event, message}, data])
    case response do
      {:reply, reply, new_state, new_data}            -> {:reply, reply, :running, {module, new_state, new_data}}
      {:reply, reply, new_state, new_data, hibernate} -> {:reply, reply, :running, {module, new_state, new_data}, :hibernate}
      {:reply, reply, new_state, new_data, timeout}   -> {:reply, reply, :running, {module, new_state, new_data}, :timeout}
      {:next_state, new_state, new_data}              -> {:next_state, :running, {module, new_state, new_data}}
      {:next_state, new_state, new_data, hibernate}   -> {:next_state, :running, {module, new_state, new_data}, :hibernate}
      {:next_state, new_state, new_data, timeout}     -> {:next_state, :running, {module, new_state, new_data}, :timeout}
      {:stop, reason, reply, new_data}                -> {:stop, reason, reply, {module, :stopped, new_data}}
      {:stop, reason, new_data}                       -> {:stop, reason, {module, :stopped, new_data}}
    end
  end
  def init(data), do: {:ok, :running, data}
  def handle_info({'EXIT', _pid, _reason}, state, data), do: {:next_state, state, data}
  def handle_sync_event(event, _from, state, data), do: {:next_state, state, data}
  def terminate(_reason, _state, _data), do: :ok
end
