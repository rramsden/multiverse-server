defmodule Packet do
  @header_size 6
  @multiverse_flag 0x5555

  def pack(opcode, payload) do
    {:ok, bin} = MessagePack.pack(payload)
    size = byte_size(bin)
    [header(opcode, size), bin]
  end

  def unpack(<<_ :: size(48), bin :: binary>>) do
    MessagePack.unpack(bin)
  end

  def header(opcode, size) do
    <<
    (@header_size + size) :: 16-unsigned-integer,
    @multiverse_flag :: size(16),
    opcode :: size(16)
    >>
  end
end
