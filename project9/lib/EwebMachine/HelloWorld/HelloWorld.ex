defmodule Server.EwebRouter do

  use Ewebmachine.Builder.Resources ; resources_plugs

  if Mix.env == :dev, do: plug Ewebmachine.Plug.Debug

  resources_plugs error_forwarding: "/error/:status", nomatch_404: true
  plug ErrorRoutes

  plug :resource_match
  plug Ewebmachine.Plug.Run
  plug Ewebmachine.Plug.Send


  resource "/api/me" do %{} after
    plug MyJSONApi
    defh resource_exists do
      IO.inspect("HERE")
      {true, conn, Map.put(state,:json_obj,%{"name"=>"Albert","id"=>1234})}
    end
  end


  resource "/api/orders" do %{} after
    plug MyJSONApi
    defh resource_exists do
      {true, conn, Map.put(state,:json_obj,Riak.afterSearch(Riak.search("*:*",0,30)))}
    end
  end

  resource "/api/order/:orderid" do %{orderid: orderid} after
    content_types_provided do: ['application/json': :to_json]
    defh to_json, do: Poison.encode!(Riak.getValueFromKey(state.orderid))
  end

  resource "/api/delete/:orderid" do %{orderid: orderid} after
    allowed_methods do: ["DELETE"]
    delete_resource do
      Riak.deleteKey(state.orderid)
      {true,conn,state}
    end
  end

  resource "/api/kbedu_orders" do %{} after
    content_types_provided do: ['application/json': :to_json]
    defh to_json do
      try do
        params = fetch_query_params(conn).query_params
        {page,_} = Integer.parse(Map.get(params,"page"))
        {rows,_} = Integer.parse(Map.get(params,"rows"))
        query = Map.get(params,"query") |> URI.encode()

        res = Riak.search((if query == "" , do: "*:*", else: query) ,page - 1,rows)
        |> Riak.afterSearch()
        |> Poison.encode!()
        res
      rescue
        e -> Poison.encode!(%{"error"=> e})
      end
      end
  end

  resource "/api/order/payment/:orderid" do %{orderid: orderid} after
    allowed_methods do: ["POST"]
    process_post do
      TransactionGenServer.makePayment(state.orderid)
      {true,conn,state}
    end
  end

  resource "/image" do %{} after

    plug ImageApi
    defh to_img do
      File.read!("priv/static/loader.gif")
    end
  end

  resource "/filepdf" do %{} after
    plug PdfApi
    defh to_pdf do
      File.read!("priv/static/sample.pdf")
    end
  end

  resource "*_" do %{} after
    plug RenderLayout
    defh resource_exists do
      {true, conn, state}
    end
  end

end
