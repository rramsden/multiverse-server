defmodule Multiverse.Entity.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link do
    Supervisor.start_link(@name, :ok, [name: @name])
  end

  def init(:ok) do
    children = []
    supervise(children, strategy: :one_for_one)
  end
end
