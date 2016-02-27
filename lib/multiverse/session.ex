defmodule Multiverse.Session do
  @behaviour Entity
  @behaviour Entity.Active
  use ExActor.GenServer

  require Logger
  alias Multiverse.Entity, as: Entity

  def init do
    Logger.info "Initializing session..."
    supervisor_pid = Multiverse.Service.lookup(:session_sup)
    {:ok, entity} = Entity.init(__MODULE__,
                                session_sup_pid: supervisor_pid,
                                auth: false)
    Entity.Active.start_entity(__MODULE__, supervisor_pid, entity, :not_auth)
  end

  def login(session, username, password) do
    {:ok, session}
  end

  def not_auth({event, message}, entity) do
    Logger.info "Received event #{event}"
    next_state = Entity.base_set(entity, auth: true)
    {:ok, :auth_ok}
  end

  # ENTITY CALLBACKS

  def start_active_trait(module, initial_state, entity) do
    Logger.info "Booting with #{initial_state}"
    Entity.Active.start_link(module, initial_state, entity)
  end

  def get(entity, key), do: Entity.base_get(entity, key)
  def set(entity, map), do: Entity.base_set(entity, map)
end
