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

    Riak.setAllStatusValuesToInit()

    ret

  end


end
