defmodule SocketSupervisor do
  use Supervisor
  require Logger
  
  @name SocketSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    port = Application.get_env(:multiverse, :port)
    {:ok, listen} = :gen_tcp.listen(port, active: :once, packet: :line)

    spawn_link(&empty_listeners/0)

    children = [
      worker(SocketServe, [listen], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_socket do
    Supervisor.start_child(@name, [])
  end

  def empty_listeners do
    for _ <- 0..10, do: start_socket()
  end
end
