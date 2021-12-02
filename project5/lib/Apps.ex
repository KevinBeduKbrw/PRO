defmodule Apps do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Server.Serv_supervisor,name: SERV,customer: Customer_DB,order: Order_DB},
      {Plug.Cowboy, scheme: :http, plug: Server.Router_Step3, options: [port: 4001]}

    ]
    opts = [strategy: :one_for_one, name: Supervisor]

    Logger.info("Vroum vroum le diesel...")

    ret = Supervisor.start_link(children, opts)
    Apps.loadJSON

    path = Path.join(File.cwd!,"resources/chap1/orders_dump/orders_chunk0.json")
    JsonLoader.load_to_database(Order_DB,path)

    ret
  end

  def loadJSON do

    GenServer.cast(Customer_DB,{:insert, "nat_order000147778" ,
    %{remoteid: "nat_order000147778",
    custom:
    %{customer: %{full_name: "TOTO & CIE"},
    billing_address: "Some where in the world"
    },
    items: 2}
    })

    GenServer.cast(Customer_DB,{:insert, "nat_order000147703" ,
    %{remoteid: "nat_order000147703",
    custom:
    %{customer: %{full_name: "Looney Toons"},
    billing_address: "The Warner Bros Company"
    },
    items: 3}
    })

    GenServer.cast(Customer_DB,{:insert, "nat_order000147800" ,
    %{remoteid: "nat_order000147800",
    custom:
    %{customer: %{full_name: "Asterix & Obelix"},
    billing_address: "Armorique"
    },
    items: 29}
    })

    GenServer.cast(Customer_DB,{:insert, "nat_order000147780" ,
    %{remoteid: "nat_order000147780",
    custom:
    %{customer: %{full_name: "Loucky Louke"},
    billing_address: "A Cowboy doesn't have an address. Sorry"
    },
    items: 0}
    })
  end
end
