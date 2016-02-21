defmodule Network.Packet.Handshake do
  import Packet
  require Logger

  @opcode 0x0000

  def handle(packet, socket) do
    {:ok, client_version} = unpack(packet)
    server_version = Multiverse.version
    success = (client_version["major"] == server_version[:major])

    payload = pack(@opcode, %{
      success: success,
      major: server_version[:major],
      minor: server_version[:minor],
      patch: server_version[:patch]
                          })

    # Send response back to client
    Network.Socket.send_packet(socket, payload)

    {:match, :ok}
  end
end
