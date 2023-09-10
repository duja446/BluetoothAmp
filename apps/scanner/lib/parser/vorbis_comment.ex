defmodule Scanner.Parser.VorbisComment do

  def parse(bistring, v \\ %{})
  def parse(<<
    length :: 32-little-unsigned-integer,
    comment :: (length * 8)-binary,
    rest :: bitstring >>, v) do

    [field, value] = String.split(comment, "=")

    field = 
      field
        |> String.downcase()
        |> String.to_atom()
        
    parse(rest, Map.put(v, field, value))
  end

  def parse(<<>>, v) do
    v
  end
  
end
