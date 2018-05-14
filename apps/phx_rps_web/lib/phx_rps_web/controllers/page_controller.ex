defmodule PhxRpsWeb.PageController do
  use PhxRpsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:csrf_token, Plug.CSRFProtection.get_csrf_token())
    |> render("index.html")
  end
end
