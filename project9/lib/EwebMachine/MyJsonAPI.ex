defmodule MyJSONApi do
  use Ewebmachine.Builder.Handlers

  plug :cors
  plug :add_handlers, init: %{}

  content_types_provided do: ["application/json": :to_json]
  defh to_json, do: Poison.encode!(state[:json_obj])

  defp cors(conn,_), do:
    put_resp_header(conn,"Access-Control-Allow-Origin","*")
end
