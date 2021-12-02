defmodule TutoElixirKBRW do
  use Application
  require Logger
  def start(_type, _args) do

    children = [
    ]
    opts = [strategy: :one_for_one, name: Supervisor]

    Logger.info("Vroum vroum le diesel...")
    Riak.start
    Supervisor.start_link(children, opts)


  end


end
