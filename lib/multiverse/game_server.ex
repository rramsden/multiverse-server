defmodule Multiverse.GameServer do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Multiverse.SessionSupervisor, [], restart: :temporary)
    ]
    supervise(children, strategy: :one_for_one)
  end
end
