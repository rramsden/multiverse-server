defmodule Network.Packet.PlayerMove do
  import Packet
  require Logger

  @opcode 0x000A

  def handle(packet, socket) do
    {:ok, data} = unpack(packet)
    Logger.info("ID ##{data["id"]} : {#{data["x"]},#{data["y"]},#{data["z"]}}")

    {:match, :ok}
  end
end
