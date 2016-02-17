defmodule Network.Packet.Handshake do
  import Packet

  @opcode 0x0000

  def handle(packet, socket) do
    version = Multiverse.version
    success = 1

    payload = [
      header(@opcode, 4),
      <<
      # success
      success :: size(8),

      # protocol version
      version[:major] :: integer,
      version[:minor] :: integer,
      version[:patch] :: integer
      >>
    ]

    Network.Serve.send_packet(socket, payload)
    {:match, :ok}
  end
end
