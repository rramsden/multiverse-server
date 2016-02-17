defmodule Network.PacketHandler do
  require Logger

  @opcodes %{
    0x0000 => Network.Packet.Handshake,
    0x0001 => Network.Packet.Disconnect
  }

  def handle(<<_ :: size(16), 0x5555 :: size(16), opcode :: size(16), _ :: binary>> = packet, socket) do
    case @opcodes[opcode] do
      nil ->
        {:error, :nomatch}
      module ->
        module.handle(packet, socket)
        {:match, :ok}
    end
  end
  def handle(binary, _socket) do
    Logger.info "Received #{binary}"
    {:error, :nomatch}
  end
end
