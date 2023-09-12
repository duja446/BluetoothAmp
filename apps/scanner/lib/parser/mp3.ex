defmodule Scanner.Parser.MP3 do
  import Bitwise
  require Logger
  
  def parse_tag(<< tag :: 24-bitstring, rest :: bitstring >>) do
    Logger.debug(inspect tag) 
    if tag == "ID3" do
      {rest, {:tag, tag}}
    else
      :error
    end
  end

  def build_map(parse_f) do
    fn {binary, map} -> 
      {rest, {field, value}} = parse_f.(binary)
      {rest, Map.put(map, field, value)} 
    end
  end


  def parse_version(<< 
    major_version :: 8, 
    _minor_version :: 8, 
    rest :: bitstring >>) do
    {rest, {:major_version, major_version}}
  end
  
  def parse_flags(<< 
    _unsynchronization :: 1,
    extended_header :: 1,
    _experimental :: 1,
    _ :: 5,
    rest :: bitstring >>) do
    {rest, {:extended_header?, extended_header}}
  end

  def parse_header_size(<< tag_size :: 32-bitstring, rest :: bitstring >>) do
    s = 
      tag_size
      |> :binary.bin_to_list()
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(0, fn {b, index}, acc -> acc ||| (b <<< (index * 7)) end) 
    {rest, {:tag_size, s}}
  end

  def parse_extended_header(3, << 
    header_size :: 32-unsigned-integer,
    _flags :: 16,
    _padding :: 32,
    rest :: bitstring >>) do

    remaining_header_size = header_size - 6
    << _ :: binary-size(remaining_header_size), rest :: bitstring >> = rest
    {rest, {:ext_header_size, header_size}}
  end

  def parse_frame(<<
    frame_id :: 32,
    size :: 32-unsigned-integer,
    rest :: bitstring >>
  ) do
    
  end

  def parsing_queue(binary) do
    {rest, data_map} =
      {binary, %{}}
      |> build_map(&parse_tag/1).()
      |> build_map(&parse_version/1).()
      |> build_map(&parse_flags/1).()
      |> build_map(&parse_header_size/1).()

    {rest, data_map} = 
      if data_map[:extended_header?] == 1 do
        build_map(&parse_extended_header(data_map[:major_version], &1)).(rest)
      else
        {rest, data_map}
      end

    data_map
  end
end
