defmodule ETS do
  def start do
    {ok,pid} = Serv_supervisor.start_link([])
    [{_, reg, _, _}] = Supervisor.which_children(pid)
    t = Database.insert(reg,"toto",{"toto", 42})
    IO.inspect(t)
  end

  def start2 do
    {:ok, sup} = CustomSupervisor.start_link([])
    Supervisor.which_children(sup)
    [{_, registry, _, _}] = Supervisor.which_children(sup)
    GenServer.call(registry, :bad_input)
    Supervisor.which_children(sup)
  end

  def startets()do
    pid = :ets.new(:ets_name, [:set, :public])
    :ets.insert(pid, {"toto", 42})
    :ets.insert(pid, {"test", "42"})
    :ets.insert(pid, {"tata", "apero?"})
    :ets.insert(pid, {"kbrw", "OH YAH"})
    :ets.match_object(pid, {:_,42})
    #:ets.select(pid,[{{'_','$1'},[],['$_']}])
  end

  def ets_start()do
    table = :ets.new(:table, [:protected, :set])

    :ets.insert(table, {1, "Alice", "Dannings"})
    :ets.insert(table, {2, "Ali", "Aaqib"})
    :ets.insert(table, {3, "Bob", "Dannings"})
    :ets.insert(table, {4, "Amanda", "Clarke"})
    :ets.insert(table, {5, "Al", "Clarke"})

    # now let's explore elixir comparison rules


    :ets.match_object(table, {:_,"Ali",:_})
    #:ets.select(table, [{{1,'_','_'},[],['$_']}])

  end

end
