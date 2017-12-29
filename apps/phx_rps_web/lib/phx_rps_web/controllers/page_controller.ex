defmodule PhxRpsWeb.PageController do
  use PhxRpsWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
