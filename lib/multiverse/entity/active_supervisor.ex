defmodule Multiverse.Entity.ActiveSupervisor do
  use Supervisor
  require Logger

  def start_link(module) do
    Logger.info "Starting active entity supervisor for #{module}..."
    Supervisor.start_link(__MODULE__, [module], [])
  end

  def init(_module) do
    children = []
    supervise(children, strategy: :one_for_one)
  end
end
