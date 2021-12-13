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
        _type = Map.get(params,"type")
        query = Map.get(params,"query") |> URI.encode()

        Poison.encode!(Riak.afterSearch(Riak.search((if query == "" , do: "*:*", else: query) ,page - 1,rows)))
      rescue
        e -> Poison.encode!(%{"error"=> e})
      end
      end
  end

  resource "/api/order/payment/:orderid" do %{orderid: orderid} after
    content_types_provided do: ['application/json': :to_json]
    defh to_json do
      Poison.encode!(Riak.getValueFromKey(state.orderid))
      TransactionGenServer.start_link()
      res = TransactionGenServer.makePayment(state.orderid)
      TransactionGenServer.stop()
      Poison.encode!(res)
    end
  end

  resource "*_" do %{} after
    plug TestRender
    defh resource_exists do
      {true, conn, state}
    end
  end

  resource "/hello/:name" do %{name: name} after
    content_types_provided do: ['text/html': :to_html]
    defh to_html, do: "<html><h1>Hello #{state.name}</h1></html>"
  end

  resource "/error/:status" do %{s: elem(Integer.parse(status),0)} after
    content_types_provided do: ['text/html': :to_html, 'application/json': :to_json]
    defh to_html, do: "<h1> Error ! : '#{Ewebmachine.Core.Utils.http_label(state.s)}'</h1>"
    defh to_json, do: ~s/{"error": #{state.s}, "label": "#{Ewebmachine.Core.Utils.http_label(state.s)}"}/
    finish_request do: {:halt,state.s}
  end
end
