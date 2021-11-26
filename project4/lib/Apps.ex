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

    Supervisor.start_link(children, opts)
  end
end
