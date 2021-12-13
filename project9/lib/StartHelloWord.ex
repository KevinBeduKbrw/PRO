defmodule StartHelloWorld do
  use Application
  def start(_type, _args), do:



    pid = Supervisor.start_link([
        Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: Server.EwebRouter, options: [port: 4002])
      ], strategy: :one_for_one)

    IO.inspect(Enum.count(Riak.getAllKeys()))


end
