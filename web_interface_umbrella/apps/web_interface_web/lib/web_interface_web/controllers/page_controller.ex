defmodule WebInterfaceWeb.PageController do
  use WebInterfaceWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
