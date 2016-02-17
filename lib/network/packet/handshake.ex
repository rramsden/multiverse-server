defmodule Network.Packet.Handshake do
  @header_size 6
  @opcode 0x0000

  def handle(packet, socket) do
    version = Multiverse.Mixfile.project[:version]

    payload = <<
    (@header_size + 4) :: 16-unsigned-integer,
    0x5555 :: size(16),
    @opcode :: size(16),
    0 :: size(8), # success
    0 :: integer, # major
    0 :: integer, # minor
    1 :: integer  # micro
    >>

    # TODO: Check Protocol Version 

    Network.Serve.send_packet(socket, payload)
    {:match, :ok}
  end
end
