defmodule Network.Supervisor do
  use Supervisor
  require Logger
  
  @name Network.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    port = Application.get_env(:multiverse, :port)
    {:ok, listen} = :gen_tcp.listen(port, active: true, packet: 0)

    spawn_link(&empty_listeners/0)

    children = [
      worker(Network.Serve, [listen], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_socket do
    Supervisor.start_child(@name, [])
  end

  def empty_listeners do
    start_socket()
    # for _ <- 0..1, do: start_socket()
  end
end
