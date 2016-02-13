defmodule SocketServe do
  use GenServer
  require Logger

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    Process.flag(:trap_exit, true)
    send(self, :accept)
    {:ok, %{socket: socket, object: {0,0,0}}}
  end

  def handle_call(_e, _from, state) do
    # never need to handle a call
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, <<"M", x :: float, y :: float, z :: float>>}, state) do
    Logger.info "Moving #{x},#{y},#{z}"
    {:noreply, state}
  end
  def handle_info({:tcp, _socket, 'QUIT' ++ _}, state) do
    :gen_tcp.close(state.socket)
    {:stop, :normal, state}
  end
  def handle_info({:tcp, _socket, binary}, state) do
    Logger.info "Unexpected Message: #{IO.inspect(binary)}"
    :ok = :inet.setopts(state.socket, [:binary, active: true])
    {:noreply, state}
  end
  def handle_info({:tcp_closed, socket}, state) do
    Logger.info "Client Connection Closed"
    {:stop, :normal, state}
  end
  def handle_info(:accept, state) do
    {:ok, client} = :gen_tcp.accept(state.socket)
    {:ok, {ip_address, port}} = :inet.peername(client)
    Logger.info "New connection from #{inspect(ip_address)}"
    :ok = :inet.setopts(client, [:binary, nodelay: true, active: true])

    # Start a new socket to replace this one
    SocketSupervisor.start_socket()

    {:noreply, Map.put(state, :socket, client)}
  end
  def handle_info(e, state) do
    Logger.info "Unexpected Message: #{inspect(e)}"
    {:noreply, state}
  end

  def terminate(:normal, state) do
    Logger.info "Terminating Acceptor"
    {:ok, state}
  end
  def terminate(reason, _state) do
    Logger.info("Unexpected Terminate Reason: #{reason}")
  end

  defp line(str) do
    String.strip(to_string(str))
  end
end
