defmodule Server.Serv_supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, opts)
  end

  @impl true
  def init(args) do
    children = [
      Supervisor.child_spec({Server.Database, {:ets.new(:ets_1, [:set, :public]), args[:customer]}}, id: args[:customer]),
      Supervisor.child_spec({Server.Database, {:ets.new(:ets_2, [:set, :public]), args[:order]}}, id: args[:order])

    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
