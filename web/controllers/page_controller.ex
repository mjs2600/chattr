defmodule Chattr.PageController do
  use Chattr.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
