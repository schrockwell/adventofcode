defmodule AdventOfCode.Day16 do
  @behaviour AdventOfCode

  defmodule Process do
    defstruct state: :version, bits: [], packet: nil, version: nil
  end

  defmodule OperatorPacket do
    defstruct version: nil, type_id: nil, subpackets: [], payload_size: nil, subpacket_count: nil
  end

  defmodule LiteralPacket do
    defstruct version: nil, type_id: 4, value: 0
  end

  def run([input]) do
    bits = Base.decode16!(input)

    {packet, _zeros} = parse(bits)

    answer_a = version_sum(packet)

    {answer_a, "todo"}
  end

  # Main entry point for parsing a single packet from a chunk of upcoming bits
  defp parse(bits) when is_bitstring(bits), do: parse(%Process{bits: bits})

  defp parse(process) do
    # Parse ONLY the next packet
    next_process = parse_next(process)

    if next_process.state == :done do
      # Emit the packet and any leftover bits if we're done
      {next_process.packet, next_process.bits}
    else
      # Otherwise, the state machine is still churning
      parse(next_process)
    end
  end

  # Parse the 3 version bits
  defp parse_next(%{state: :version, bits: <<version::3, bits::bitstring>>} = process) do
    %{process | state: :type_id, version: version, bits: bits}
  end

  # Parse the type ID and build the appropriate packet struct
  defp parse_next(%{state: :type_id, bits: <<type_id::3, bits::bitstring>>} = process) do
    if type_id == 4 do
      packet = %LiteralPacket{version: process.version}
      %{process | state: {:literal, :value}, packet: packet, bits: bits}
    else
      packet = %OperatorPacket{version: process.version}
      %{process | state: {:operator, :type}, packet: packet, bits: bits}
    end
  end

  # Parse the literal value, iterating while MSB of this chunk is 1
  defp parse_next(
         %{state: {:literal, :value}, bits: <<continue::1, value::4, bits::bitstring>>} = process
       ) do
    import Bitwise

    value = (process.packet.value <<< 4) + value
    packet = %{process.packet | value: value}

    process = %{process | bits: bits, packet: packet}

    if continue == 1 do
      process
    else
      %{process | state: :done}
    end
  end

  # If the length type ID is 0, then the next 15 bits are a number that represents the total
  # length in bits of the sub-packets contained by this packet.
  defp parse_next(
         %{state: {:operator, :type}, bits: <<0::1, payload_size::15, bits::bitstring>>} = process
       ) do
    packet = %{process.packet | payload_size: payload_size}

    %{process | state: {:operator, :subpackets}, bits: bits, packet: packet}
  end

  # If the length type ID is 1, then the next 11 bits are a number that represents the number
  # of sub-packets immediately contained by this packet.
  defp parse_next(
         %{state: {:operator, :type}, bits: <<1::1, subpacket_count::11, bits::bitstring>>} =
           process
       ) do
    packet = %{process.packet | subpacket_count: subpacket_count}

    %{process | state: {:operator, :subpackets}, bits: bits, packet: packet}
  end

  # No payload bits remaining, so we're done
  defp parse_next(%{state: {:operator, :subpackets}, packet: %{payload_size: 0}} = process) do
    %{process | state: :done}
  end

  # Finally, after the length type ID bit and the 15-bit or 11-bit field, the sub-packets appear.
  # Append the next subpacket by launching a whole new parser.
  defp parse_next(
         %{state: {:operator, :subpackets}, packet: %{payload_size: payload_size}} = process
       )
       when is_integer(payload_size) and payload_size > 0 do
    starting_bits = bit_size(process.bits)
    <<sub_bits::bitstring-size(payload_size), bits_2::bitstring>> = process.bits

    {subpacket, bits_1} = parse(sub_bits)

    next_bits = <<bits_1::bitstring, bits_2::bitstring>>
    ending_bits = bit_size(next_bits)
    bits_consumed = starting_bits - ending_bits
    next_payload_size = payload_size - bits_consumed

    next_packet = %{
      process.packet
      | subpackets: [subpacket | process.packet.subpackets],
        payload_size: next_payload_size
    }

    %{process | packet: next_packet, bits: next_bits}
  end

  # Same as above, except the counter is easier
  defp parse_next(%{state: {:operator, :subpackets}, packet: %{subpacket_count: 0}} = process) do
    %{process | state: :done}
  end

  defp parse_next(
         %{state: {:operator, :subpackets}, packet: %{subpacket_count: subpacket_count}} = process
       )
       when is_integer(subpacket_count) and subpacket_count > 0 do
    {subpacket, next_bits} = parse(process.bits)

    next_packet = %{
      process.packet
      | subpackets: process.packet.subpackets ++ [subpacket],
        subpacket_count: subpacket_count - 1
    }

    %{process | packet: next_packet, bits: next_bits}
  end

  # Answer for part 1
  defp version_sum(%OperatorPacket{subpackets: subpackets, version: version}) do
    subpacket_sum =
      subpackets
      |> Enum.map(&version_sum/1)
      |> Enum.sum()

    version + subpacket_sum
  end

  defp version_sum(%LiteralPacket{version: version}), do: version
end
