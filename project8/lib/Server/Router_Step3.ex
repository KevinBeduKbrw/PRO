defmodule Server.Router_Step3 do
  require EEx
  EEx.function_from_file :defp, :layout, "./web/layout.html.eex", [:render]
  use Plug.Router


  #plug Plug.Static, from: "priv/static", at: "/static"
  plug Plug.Static,  from: :tutokbrwstack, at: "/public"
  plug(:match)
  plug(:dispatch)



  get "/api/me", do: getUser(conn)

  get "/api/orders", do: getOrders(conn)

  get "/api/order/*glob", do: getOrder(conn)

  get "/api/kbedu_orders", do: search(conn)

  delete "/api/delete/*glob", do: deleteOrder(conn)

  get "/static/loader.gif", do: send_file(conn, 200, "priv/static/loader.gif")

  get _ do
    conn = fetch_query_params(conn)
    render = Reaxt.render!(:app, %{path: conn.request_path, cookies: conn.cookies, query: conn.params},30_000)
    send_resp(put_resp_header(conn,"content-type","text/html;charset=utf-8"), render.param || 200,layout(render))
  end
  #get _, do: send_file(conn, 200, "priv/static/index.html")

  #match _, do: send_resp(conn, 404, "Page Not Found")

  defp getUser(conn) do
    res = Poison.encode!(%{
      "name" => "Tabernacle",
      "id" => 1234})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, res)
  end


  defp getOrders(conn) do
    msg = {:ok,{{_,errorCode,_message},headers,body}} = Riak.search("*:*",0,30)

    res = afterSearch(body)

    case errorCode do
      200 -> conn |> put_resp_content_type("application/json") |> send_resp(200, res)
      _   -> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!([]))
    end
  end

  defp getOrder(conn) do
    conn = fetch_query_params(conn)
    id = Map.get(conn.params,"glob")
    |> List.to_string()


    {:ok,{{_,errorCode,_message},_headers,body}} = Riak.getValueFromKey(id)
    res = body
    |> to_string
    |> Poison.decode!

    case errorCode do
      404 -> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!([]))
      _   -> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(res))
    end
  end

  defp deleteOrder(conn) do
    conn = fetch_query_params(conn)
    id = Map.get(conn.params,"glob")
    |> List.to_string()

    {:ok,{{_,errorCode,_message},_headers,body}} = Riak.deleteKey(id)

    :timer.sleep(1000);
    case errorCode do
      204 -> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(%{"value" => "OK"}))
      404 -> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(%{"value" => "NOT FOUND"}))
      _-> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(%{"value" => "NOT OK"}))
    end
  end

  defp search(conn) do
    params = fetch_query_params(conn).query_params

    {page,_} = Integer.parse(Map.get(params,"page"))
    {rows,_} = Integer.parse(Map.get(params,"rows"))
    type = Map.get(params,"type")

    query = Map.get(params,"query")
    |> URI.encode()

    msg = {:ok,{{_,errorCode,_message},headers,body}} = Riak.search((if query == "" , do: "*:*", else: query) ,page - 1,rows)

    res = afterSearch(body)

    case errorCode do
      200 -> conn |> put_resp_content_type("application/json") |> send_resp(200, res)
      _   -> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!([]))
    end
  end

  defp afterSearch(body) do
    res = body
    |> to_string
    |> Poison.decode!
    |> Map.get("response")
    |> Map.get("docs")
    |> Enum.reduce([],fn x,acc -> [Map.get(x,"id")|acc] end)
    |> List.flatten()
    |> Task.async_stream(Riak, :getValueFromKey, [], max_concurrency: 10)
    |> Enum.map(fn {:ok, {:ok,{{_,ec,_message},hd,bd}}} -> Poison.decode!(to_string(bd)) end)
    |> Poison.encode!()
  end


  defp getOrders_OLD(conn) do
    x = Server.Database.selectall(Elixir.Order_DB)
    |> Enum.reverse()
    |> Enum.reduce([], fn {z,c},acc-> [c | acc] end)
    |> Poison.encode!()


    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, x)
  end

  defp getOrder_OLD(conn) do
    conn = fetch_query_params(conn)
    id = Map.get(conn.params,"glob")
    |> List.to_string()
    IO.inspect(Server.Database.getallkeys(Elixir.Order_DB))
    val = Server.Database.select(Elixir.Order_DB,id)
    case val do
      [] -> send_resp(conn, 404, "no id")
      _-> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(elem(Enum.at(val,0),1)))
    end
  end

  defp deleteOrder_OLD(conn) do
    conn = fetch_query_params(conn)
    id = Map.get(conn.params,"glob")
    |> List.to_string()

    val = Server.Database.delete(Elixir.Customer_DB,id)
    :timer.sleep(1000);
    case val do
      :ok -> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(%{"value" => "OK"}))
      _-> conn |> put_resp_content_type("application/json") |> send_resp(200, Poison.encode!(%{"value" => "NOT OK"}))
    end
  end



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
    Server.Database.insert(Elixir.Customer_DB,id,value)
    send_resp(conn, 200, "Insertion ok avec id : "<> id <> " value : "<> value)
  end

  defp isudHandler(:select,conn,id,_value) do
    select = Server.Database.select(Elixir.Customer_DB,id)
    case select do
      [] -> send_resp(conn, 200, "La bdd ne contient pas cet id")
        [{_,value}]-> send_resp(conn, 200, "Valeur : "<> value)
    end
  end

  defp isudHandler(:update,conn,id,value) do
    Server.Database.update(Elixir.Customer_DB,id,value)
    send_resp(conn, 200, "Modification ok pour id : "<> id <> " new value : "<> value)
  end

  defp isudHandler(:delete,conn,id,_value) do
    Server.Database.delete(Elixir.Customer_DB,id)
    send_resp(conn, 200, "Valeur id : "<> id <> " DELETEEEEED")
  end

  defp isudHandler(:search,conn) do
    IO.inspect(conn)
    conn = fetch_query_params(conn)
    IO.inspect(conn.params)
    #search = Server.Database.search(Elixir.Customer_DB,criteria)
    #IO.inspect(search)
    send_resp(conn, 200, "Not implemented IOTiredException")
  end





  defp isEmptyOrNil(nil), do: true
  defp isEmptyOrNil(str) do
    str
    |>String.trim()
    |>String.length == 0
  end

end
