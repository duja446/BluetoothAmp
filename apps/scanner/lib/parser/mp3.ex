defmodule Scanner.Parser.MP3 do
  import Bitwise
  require Logger

  @valid_tags ["AENC", "APIC", "ASPI", "COMM", "COMR", "ENCR", "EQU2", "ETCO", "GEOB", "GRID", "LINK", "MCDI", "MLLT", "OWNE", "PRIV", "PCNT", "POPM", "POSS", "RBUF", "RVA2", "RVRB", "SEEK", "SIGN", "SYLT", "SYTC", "TALB", "TBPM", "TCOM", "TCON", "TCOP", "TDEN", "TDLY", "TDOR", "TDRC", "TDRL", "TDTG", "TENC", "TEXT", "TFLT", "TIPL", "TIT1", "TIT2", "TIT3", "TKEY", "TLAN", "TLEN", "TMCL", "TMED", "TMOO", "TOAL", "TOFN", "TOLY", "TOPE", "TOWN", "TPE1", "TPE2", "TPE3", "TPE4", "TPOS", "TPRO", "TPUB", "TRCK", "TRSN", "TRSO", "TSOA", "TSOP", "TSOT", "TSRC", "TSSE", "TSST", "TXXX", "UFID", "USER", "USLT", "WCOM", "WCOP", "WOAF", "WOAR", "WOAS", "WORS", "WPAY", "WPUB", "WXXX"]
  
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

  def parse_frames(
    major_version,
    <<
      frame_id :: 4-binary,
      frame_size :: 32-unsigned-integer,
      _flags :: 16,
      rest :: bitstring 
    >>,
    tag_length_remaining,
    frames
  ) do
    
    total_frame_size = frame_size + 10
    next_tag_length_remaining = tag_length_remaining - total_frame_size

    result = decode_frame(frame_id, frame_size, rest)

    case result do
      {rest, :stop} ->
        {rest, Map.new(frames)}

      {rest, :continue} ->
        parse_frames(major_version, rest, next_tag_length_remaining, frames)

      {rest, frame} -> 
        parse_frames(major_version, rest, next_tag_length_remaining, [frame | frames])
    end
  end

  def decode_frame(id, frame_size, rest) do
    Logger.debug(id)
    cond do
      id == "TALB" -> 
        {strs, rest} = decode_text_frame(frame_size, rest) 
        {rest, {:album, Enum.at(strs, 0)}} 

      id == "TIT2" ->
        {strs, rest} = decode_text_frame(frame_size, rest) 
        {rest, {:title, Enum.at(strs, 0)}} 

      id == "TPE1" ->
        {strs, rest} = decode_text_frame(frame_size, rest) 
        {rest, {:artist, Enum.at(strs, 0)}} 

      id == "TRCK" ->
        {strs, rest} = decode_text_frame(frame_size, rest) 
        {rest, {:tracknumber, get_trck(strs)}} 

      id in @valid_tags ->
        << _frame_data :: size(frame_size)-binary, rest :: bitstring >> = rest
        {rest, :continue}

      true -> 
        {rest, :stop}
    end
  end

  def get_trck(strs) do
    Enum.at(strs, 0)
    |> String.split("/")
    |> Enum.at(0) 
    |> String.to_integer()
  end

  def decode_text_frame(frame_size, <<text_encoding::size(8), rest::binary>>) do
    {strs, rest} = decode_string_sequence(text_encoding, frame_size - 1, rest)
    {strs, rest}
  end

  def decode_string_sequence(encoding, max_byte_size, data, acc \\ [])

  def decode_string_sequence(_, max_byte_size, data, acc) when max_byte_size <= 0 do
    {Enum.reverse(acc), data}
  end

  def decode_string_sequence(encoding, max_byte_size, data, acc) do
    {str, str_size, rest} = decode_string(encoding, max_byte_size, data)
    decode_string_sequence(encoding, max_byte_size - str_size, rest, [str | acc])
  end

  def decode_string(encoding, max_byte_size, data) when encoding in [1, 2] do
    {str_data, rest} = get_double_null_terminated(data, max_byte_size)

    {convert_string(encoding, str_data), byte_size(str_data) + 2, rest}
  end

  def decode_string(encoding, max_byte_size, data) when encoding in [0, 3] do
    case :binary.split(data, <<0>>) do
      [str, rest] when byte_size(str) + 1 <= max_byte_size ->
      {str, byte_size(str) + 1, rest}

    _ ->
      {str, rest} = :erlang.split_binary(data, max_byte_size)
      {str, max_byte_size, rest}
    end
  end

  def get_double_null_terminated(data, max_byte_size, acc \\ [])

  def get_double_null_terminated(rest, 0, acc) do
    {acc |> Enum.reverse() |> :binary.list_to_bin(), rest}
  end

  def get_double_null_terminated(<<0, 0, rest::binary>>, _, acc) do
    {acc |> Enum.reverse() |> :binary.list_to_bin(), rest}
  end

  def get_double_null_terminated(<<a::size(8), b::size(8), rest::binary>>, max_byte_size, acc) do
    next_max_byte_size = max_byte_size - 2
    get_double_null_terminated(rest, next_max_byte_size, [b, a | acc])
  end

  def convert_string(encoding, str) when encoding in [0, 3] do
    str
  end

  def convert_string(1, str) do
    {encoding, bom_length} = :unicode.bom_to_encoding(str)
    {_, string_data} = String.split_at(str, bom_length)
    :unicode.characters_to_binary(string_data, encoding)
  end

  def convert_string(2, str) do
    :unicode.characters_to_binary(str, {:utf16, :big})
  end

  def parse_data(binary) do
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

    total_tag_size = data_map[:tag_size] - Map.get(data_map, :ext_header_size, 0)
    {rest, data} = parse_frames(data_map[:major_version], rest, total_tag_size, [])
    data = handle_missing_data(data)
    {rest, Map.merge(data_map, data)}
  end

  def handle_missing_data(data) do
    data
    |> Map.put_new(:artist, "X")
    |> Map.put_new(:album, "X")
    |> Map.put_new(:title, "X")
    |> Map.put_new(:tracknumber, 0)
  end

  def parse(file) do
    {:ok, binary} = :file.read_file(file)
    {rest, data} = parse_data(binary)
    duration = Scanner.Parser.MP3Duration.duration(rest)
    %{data: data, file_info: %{path: file}, stream_info: %{duration: floor(duration * 1000)}}
  end
end
