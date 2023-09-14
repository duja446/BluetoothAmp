defmodule BluetoothAmpWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  def cut_text(text) do
    if String.length(text) < 36 do
      text
    else
      String.slice(text, 0, 36) <> " ..."
    end
  end

  def get_cover(album_name) do
    "/covers/#{album_name}.jpg"
  end

end
