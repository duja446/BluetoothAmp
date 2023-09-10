defmodule BluetoothAmpWeb.B3 do

  def upload(name, file_path, quality \\ 100) do
    HTTPoison.post!(
      "#{Application.get_env(:bluetooth_amp_web, :file_server)}/upload", 
      {:multipart, [
        {"name", name},
        {"quality", Integer.to_string(quality)},
        {:file, file_path}
      ]}
    )
  end

  def get_url(name) do
    "http://#{Application.get_env(:bluetooth_amp_web, :file_server)}/files/#{name}"
  end

  
end
