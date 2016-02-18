defmodule Network.Packet.Handshake do
  import Packet
  require Logger

  @opcode 0x0000

  def handle(packet, socket) do
    client_version = parse(packet)
    server_version = Multiverse.version
    success = if (client_version[:major] == server_version[:major]), do: 1, else: 0

    payload = [
      header(@opcode, 4),
      <<
      # success
      success :: size(8),

      # protocol version
      server_version[:major] :: integer,
      server_version[:minor] :: integer,
      server_version[:patch] :: integer
      >>
    ]

    # Send response back to client
    Network.Serve.send_packet(socket, payload)

    {:match, :ok}
  end

  def parse(<<_ :: size(48), major :: integer, minor :: integer, patch :: integer>>) do
    %{major: major, minor: minor, patch: patch}
  end
end
