defmodule Server.Router_Step3 do
  use Plug.Router

  plug Plug.Static, from: "priv/static", at: "/static"
  plug(:match)
  plug(:dispatch)



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

  get "/api/me", do: getUser(conn)

  get "/api/orders", do: getOrders(conn)

  get "/api/order/*glob", do: getOrder(conn)

  delete "/api/delete/*glob", do: deleteOrder(conn)

  get _, do: send_file(conn, 200, "priv/static/index.html")

  #match _, do: send_resp(conn, 404, "Page Not Found")


  defp getUser(conn) do
    res = Poison.encode!(%{
      "name" => "Guillaume",
      "id" => 1234})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, res)
  end

  defp getOrders(conn) do
    x = Server.Database.selectall(Elixir.Customer_DB)
    |> Enum.reverse()
    |> Enum.reduce([], fn {z,c},acc-> [c | acc] end)
    |> Poison.encode!()


    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, x)
  end

  defp getOrder(conn) do
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

  defp deleteOrder(conn) do
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
