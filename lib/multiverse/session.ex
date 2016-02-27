defmodule Multiverse.Session do
  @behaviour Entity

  require Logger
  alias Multiverse.Entity, as: Entity

  def login(session, username, password) do
    {:ok, session}
  end

  def init(service_pid) do
    Logger.info "Initializing session..."

    session_sup_pid = Multiverse.Service.lookup(service_pid, :session_sup)
    entity = Entity.init(__MODULE__,
      service_pid: service_pid,
      session_sup_pid: session_sup_pid
    )

    session = Entity.Active.init(__MODULE__, service_pid, entity, :not_auth)

    {:ok, session}
  end
  def get(entity, key), do: Entity.base_get(entity, key)
  def set(entity, map), do: Entity.base_set(entity, map)
end
