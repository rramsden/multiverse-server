defmodule Network.Socket do
  use GenServer
  require Logger

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    send(self, :accept)
    {:ok, %{socket: socket}}
  end

  def handle_info({:tcp, _socket, binary}, state) do
    Logger.info "Received Packet"
    case Network.PacketHandler.handle(binary, state.socket) do
      {:error, :nomatch} ->
        Logger.info "Bad Packet"
      {:match, reply} ->
        Logger.info "Match"
    end
    {:noreply, state}
  end
  def handle_info({:tcp_closed, socket}, state) do
    Logger.info "Client Connection Closed"
    {:stop, :normal, state}
  end
  def handle_info(:accept, state) do
    {:ok, client} = :gen_tcp.accept(state.socket)
    :ok = :inet.setopts(client, [:binary, packet: 0])
    {:ok, {ip_address, port}} = :inet.peername(client)
    Logger.info "New connection from #{inspect(ip_address)}"

    # Start a new socket to replace this one
    Network.Supervisor.start_socket()

    # Start a Player Process
    {:ok, player} = Player.start_link

    {:noreply, %{socket: client, player: player}}
  end
  def handle_info(e, state) do
    Logger.info "Unexpected Message: #{inspect(e)}"
    {:noreply, state}
  end

  def handle_call(_e, _from, state) do
    {:noreply, state}
  end

  def terminate(:normal, state) do
    Logger.info "Terminating Acceptor"
    {:ok, state}
  end
  def terminate(reason, _state) do
    Logger.info("Unexpected Terminate Reason: #{reason}")
  end

  def send_packet(socket, payload) do
    :gen_tcp.send(socket, payload)
  end
end
