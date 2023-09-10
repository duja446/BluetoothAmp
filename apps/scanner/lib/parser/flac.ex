defmodule Scanner.Parser.Flac do
  require Logger

  def block_type_str(block_type) do
    case block_type do
      0 -> 
        "STREAMINFO"
      1 ->
        "PADDING"
      2 -> 
        "APPLICATION"
      3 ->
        "SEEKTABLE"
      4 -> 
        "VORBIS_COMMENT"
      5 ->
        "CUESHEET"
      6 -> 
        "PICTURE"
      127 ->
        "INVALID"
      _ -> 
        "RESERVED"
    end
  end

  def parse(file) do
    file
    |> :file.read_file()
    |> elem(1)
    |> parse_type!()
    |> parse_metadata()
    |> Map.put(:file_info, %{path: file})
  end

  def parse_type(<< flac :: 32, rest :: bitstring >>) do
    Logger.info(flac)
    if flac == "fLaC" do
      {:ok, rest}
    else
      {:error, :not_flac}
    end
  end

  def parse_type!(<< _flac :: 32, rest :: bitstring >>) do
    rest
  end

  def parse_metadata(<< 
    is_last :: size(1),
    block_type :: size(7),
    length :: size(24),
    data :: (length * 8)-binary,
    rest :: bitstring >> ) do

    if is_last == 1 do
      %{}
    else
      case parse_metadata_block_data(block_type, data) do
        {key, val} -> Map.put(parse_metadata(rest), key, val)
        _ -> parse_metadata(rest)
          
      end
    end
  end

  def parse_metadata_block_data(0, <<
    min_block_size :: 16,
    max_block_size :: 16,
    min_frame_size :: 24,
    max_frame_size :: 24,
    sample_rate :: 20-unsigned-integer,
    n_channels :: 3,
    bits_per_sample :: 5,
    total_samples :: 36,
    md5_sig :: 128,
    >>) do

    stream_info = %{
      duration: trunc(Float.round(total_samples / sample_rate, 2) * 1000)
    }
    Logger.debug("Sample rate: #{inspect sample_rate}")
    Logger.debug("Total samples: #{inspect total_samples}")
    
    {:stream_info, stream_info}
    
  end

  # VORBIS comment
  def parse_metadata_block_data(4, << 
    vendor_length :: size(32)-little-unsigned-integer, 
    vendor_string :: (vendor_length * 8)-binary,
    _user_comment_list_length :: 32-little-unsigned-integer,
    user_comment_list :: bitstring >>) do
    
    Logger.debug("Parsing VORBIS COMMENT")
    Logger.debug("Vendor length: #{inspect vendor_length * 8}")
    Logger.debug("Vendor string: #{inspect vendor_string}")
    v = Scanner.Parser.VorbisComment.parse(user_comment_list)
    Logger.debug("Comment list: #{inspect v}")
    {:vorbis_comment, v}
  end

  def parse_metadata_block_data(6, <<
    type :: 32,
    mime_length :: 32,
    mime_type :: (mime_length * 8),
    description_length :: 32,
    description :: (description_length * 8),
    width :: 32,
    height :: 32,
    _color_depth :: 32,
    _number_of_colors :: 32,
    _data_length :: 32,
    data :: bitstring >> ) do

    Logger.info("Type: #{inspect type}")
    Logger.info("Mime type: #{inspect mime_type}")
    Logger.info("Description: #{inspect description}")
    Logger.info("Dimesions: #{inspect width}x#{inspect height}")
    Logger.info("Type: #{inspect type}")
    #File.write!("./img.")

  end

  def parse_metadata_block_data(block_type, _) do
    Logger.debug("Cant parse block data of type #{block_type_str block_type}")
  end

end
