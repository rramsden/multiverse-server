defmodule Packet do
  @header_size 6
  @multiverse_flag 0x5555

  
def header(opcode, size) do
    <<
    (@header_size + size) :: 16-unsigned-integer,
    @multiverse_flag :: size(16),
    opcode
    >>
  end
end
