defmodule Chattr.PageControllerTest do
  use Chattr.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "elm-main"
  end
end
