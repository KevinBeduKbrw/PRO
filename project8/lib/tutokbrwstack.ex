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
      {Plug.Cowboy, scheme: :http, plug: Server.Router_Step3, options: [port: 4001]}

    ]
    opts = [strategy: :one_for_one, name: Supervisor]

    Logger.info("Vroum vroum le diesel...")

    ret = Supervisor.start_link(children, opts)

    #Riak.setAllStatusValuesToInit()
    order = Riak.getValueFromKey("nat_order000147707")
    |> Map.put("payment_method","idk")



    {:next_state, {old_state,updated_order}} = ExFSM.Machine.event(order, {:process_payment, []})
    {:next_state, {old_state,updated_order}} = ExFSM.Machine.event(updated_order, {:verfication, []})

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
