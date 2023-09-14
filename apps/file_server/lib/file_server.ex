defmodule FileServer do

  def upload(name, file_path, quality \\ 100) do
    HTTPoison.post!(
      "#{Application.get_env(:file_server, :address)}/upload", 
      {:multipart, [
        {"name", name},
        {"quality", Integer.to_string(quality)},
        {:file, file_path}
      ]}
    )
  end

  def get_url(name) do
    "http://#{Application.get_env(:file_server, :address)}/files/#{name}"
  end
end
