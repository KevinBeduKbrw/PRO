defmodule Server.Router_Step3 do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/", do: send_resp(conn, 200, "Welcome")

  get "/select/*glob" do
    isudDispatch(conn,:select,true,false)
  end

  get "/insert/*glob" do
    isudDispatch(conn,:insert,true,true)
  end

  get "/update/*glob" do
    isudDispatch(conn,:update,true,true)
  end

  get "/delete/*glob" do
    isudDispatch(conn,:delete,true,false)
  end

  get "/search/*glob" do
    #isudDispatch(conn,:search,true,false)
    isudHandler(:search,conn)
  end

  match _, do: send_resp(conn, 404, "Page Not Found")


  defp isudDispatch(conn,cmd,isIdNecessary,isValueNecessary) do
    conn = fetch_query_params(conn)
    id = Map.get(conn.params,"id")
    value = Map.get(conn.params,"value")

    cond do
      isEmptyOrNil(id) and isIdNecessary -> send_resp(conn, 404, "no id")
      isEmptyOrNil(value) and isValueNecessary -> send_resp(conn, 404, "no value")
      true -> isudHandler(cmd,conn,id,value)
    end
  end

  defp isudHandler(:insert,conn,id,value) do
    Server.Database.insert(Elixir.TheDB,id,value)
    send_resp(conn, 200, "Insertion ok avec id : "<> id <> " value : "<> value)
  end

  defp isudHandler(:select,conn,id,_value) do
    select = Server.Database.select(Elixir.TheDB,id)
    case select do
      [] -> send_resp(conn, 200, "La bdd ne contient pas cet id")
        [{_,value}]-> send_resp(conn, 200, "Valeur : "<> value)
    end
  end

  defp isudHandler(:update,conn,id,value) do
    Server.Database.update(Elixir.TheDB,id,value)
    send_resp(conn, 200, "Modification ok pour id : "<> id <> " new value : "<> value)
  end

  defp isudHandler(:delete,conn,id,_value) do
    Server.Database.delete(Elixir.TheDB,id)
    send_resp(conn, 200, "Valeur id : "<> id <> " DELETEEEEED")
  end

  defp isudHandler(:search,conn) do
    conn = fetch_query_params(conn)
    id = Map.get(conn.params,"id")
    value = Map.get(conn.params,"value")
    IO.inspect(id)
    IO.inspect(value)

    {_,res} = Server.Database.search(Elixir.TheDB,[{id,value}])
    IO.inspect(res)
    conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(res))
  end





  defp isEmptyOrNil(nil), do: true
  defp isEmptyOrNil(str) do
    str
    |>String.trim()
    |>String.length == 0
  end

end
