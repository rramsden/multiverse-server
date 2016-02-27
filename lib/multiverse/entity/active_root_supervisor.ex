defmodule Multiverse.Entity.ActiveRootSupervisor do
  use Supervisor
  require Logger

  def start_link do
    Logger.info "Starting ActiveRootSupervisor..."
    Supervisor.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    supervise([], strategy: :one_for_one)
  end

  def start_active_entity_sup(pid, module) do
    child_spec = supervisor(Multiverse.Entity.ActiveSupervisor, [module],
                          restart: :permenant)

    Supervisor.start_child(pid, child_spec)
  end
end

