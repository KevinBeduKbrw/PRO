defmodule Apps do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Server.Serv_supervisor,name: SERV,dbname: TheDB},
      {Plug.Cowboy, scheme: :http, plug: Server.Router_Step3, options: [port: 4001]}

    ]
    opts = [strategy: :one_for_one, name: Supervisor]

    Logger.info("Vroum vroum le diesel...")

    ret = Supervisor.start_link(children, opts)


    #GenServer.cast(TheDB,{:insert, "000000189" ,
    #"{'remoteid': '000000189','custom': {'customer': {'full_name': 'TOTO & CIE'},'billing_address': 'Some where in the world'},'items': 2}"})
    #GenServer.cast(TheDB,{:insert, "000000190" ,
    #"{'remoteid': '000000190','custom': {'customer': {'full_name': 'Looney Toons'},'billing_address': 'The Warner Bros Company'},'items': 3}"})
    #GenServer.cast(TheDB,{:insert, "000000191" ,
    #"{'remoteid': '000000191','custom': {'customer': {'full_name': 'Asterix & Obelix'}, 'billing_address': 'Armorique'},'items': 29}"})
    #GenServer.cast(TheDB,{:insert, "000000192" ,
    #"{'remoteid': '000000192','custom': {'customer': {'full_name': 'Lucky Luke'},'billing_address': 'A Cowboy doesn't have an address. Sorry'},'items': 0}"})

    GenServer.cast(TheDB,{:insert, "000000189" ,
    %{remoteid: "000000189",
    custom:
    %{customer: %{full_name: "TOTO & CIE"},
    billing_address: "Some where in the world"
    },
    items: 2}
    })

    GenServer.cast(TheDB,{:insert, "000000190" ,
    %{remoteid: "000000190",
    custom:
    %{customer: %{full_name: "Looney Toons"},
    billing_address: "The Warner Bros Company"
    },
    items: 3}
    })

    GenServer.cast(TheDB,{:insert, "000000191" ,
    %{remoteid: "000000191",
    custom:
    %{customer: %{full_name: "Asterix & Obelix"},
    billing_address: "Armorique"
    },
    items: 29}
    })

    GenServer.cast(TheDB,{:insert, "000000192" ,
    %{remoteid: "000000192",
    custom:
    %{customer: %{full_name: "Loucky Louke"},
    billing_address: "A Cowboy doesn't have an address. Sorry"
    },
    items: 0}
    })
    ret
  end
end
