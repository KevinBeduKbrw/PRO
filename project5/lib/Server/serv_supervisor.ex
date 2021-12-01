defmodule Server.Serv_supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(args) do
    children = [
      {Server.Database, {:ets.new(:ets_name, [:set, :public]), args[:dbname]} }
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
