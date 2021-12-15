defmodule TutoKBRWStack do
  use Application
  require Logger
  def start(_type, _args) do


    Application.put_env(
      :reaxt,:global_config,
      Map.merge(
        Application.get_env(:reaxt,:global_config), %{localhost: "http://localhost:4001"}
      )
    )
    Reaxt.reload


    children = [
      {Server.Serv_supervisor,name: SERV,customer: Customer_DB,order: Order_DB},
      {Plug.Cowboy, scheme: :http, plug: Server.Router_Step3, options: [port: 4001]},
      {Plug.Cowboy, scheme: :http, plug: Server.EwebRouter, options: [port: 4002]}

    ]
    opts = [strategy: :one_for_one, name: Supervisor]

    Logger.info("Tchou tchou le batô...")

    ret = Supervisor.start_link(children, opts)
    IO.inspect(Map.count(Riak.getAllKeys()))


    #updated_order = Map.put(updated_order,"payment_method",updated_order["custom"]["magento"]["payment"]["method"])
    #rrr = MyRules.apply_rules(updated_order,[])
    #IO.inspect(updated_order)
    #IO.inspect(updated_order["status"]["state"])

    ret
  end

  def tosave do
    res = Riak.getAllKeys()
    |> Enum.map(fn key -> Riak.getValueFromKey(key) end)
    |> Enum.reduce(%{},fn key,acc ->
      {:ok,{{_,errorCode,_message},_headers,body}} = key
      res = body
      |> to_string
      |> Poison.decode!
      Map.put(acc,res["custom"]["magento"]["payment"]["method"],"method") end)
    |> IO.inspect()
  end

end
