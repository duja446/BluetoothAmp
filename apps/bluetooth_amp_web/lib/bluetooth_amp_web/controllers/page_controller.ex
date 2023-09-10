defmodule BluetoothAmpWeb.PageController do
  use BluetoothAmpWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
