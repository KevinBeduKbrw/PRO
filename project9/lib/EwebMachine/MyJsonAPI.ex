defmodule MyJSONApi do
  use Ewebmachine.Builder.Handlers

  plug :cors
  plug :add_handlers, init: %{}

  content_types_provided do: ["application/json": :to_json]
  defh to_json, do: Poison.encode!(state[:json_obj])

  defp cors(conn,_), do:
    put_resp_header(conn,"Access-Control-Allow-Origin","*")
end

defmodule TestRender do
  use Ewebmachine.Builder.Handlers
  require EEx
  EEx.function_from_file :defp, :layout, "./web/layout.html.eex", [:render]
  plug Plug.Static,  from: :tutokbrwstack, at: "/public"

  plug :cors
  plug :add_handlers, init: %{}


  defh to_html do
    IO.inspect("ICI")
    conn = fetch_query_params(conn)
    render = Reaxt.render!(:app, %{path: conn.request_path, cookies: conn.cookies, query: conn.params},30_000)
    status = render.param || 200
    layout(render)
  end

  defp cors(conn,_), do:
    put_resp_header(conn,"content-type","text/html;charset=utf-8")
end