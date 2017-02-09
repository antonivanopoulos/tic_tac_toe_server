defmodule TicTacServer.PageController do
  use TicTacServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
