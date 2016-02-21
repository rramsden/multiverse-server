defmodule Multiverse.Service do
  use Supervisor

  @name Multiverse.Service

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [worker(Multiverse.GameServer, [], restart: :permanent)]
    supervise(children, strategy: :one_for_one)
  end
end
