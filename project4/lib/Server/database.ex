defmodule Server.Database do
  use GenServer

  def start_link({initial_value,name}) do
    GenServer.start_link(__MODULE__, initial_value, name: name)
  end

  def insert(server,key,value) do
    GenServer.cast(server, {:insert,key, value})
  end
  def select(server,key) do
    GenServer.call(server, {:select,key})
  end
  def update(server,key, value) do
    GenServer.cast(server, {:update, key, value})
  end
  def delete(server,key) do
    GenServer.cast(server, {:delete, key})
  end
  def search(server,criteria)do
    GenServer.call(server,{:search , criteria })
  end

  #opt
  def selectall(server) do
    GenServer.call(server, {:select_all})
  end
  def getallkeys(server) do
    GenServer.call(server, {:get_all_keys})
  end
  def count(server) do
    GenServer.call(server, {:count})
  end


  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_cast({:insert,key ,value}, intern_state) do
    :ets.insert(intern_state, {key, value})
    {:noreply, intern_state}
  end

  @impl true
  def handle_cast({:update,key ,value}, intern_state) do
    :ets.insert(intern_state, {key, value})
    {:noreply, intern_state}
  end

  @impl true
  def handle_cast({:delete,key}, intern_state) do
    :ets.delete(intern_state, key)
    {:noreply, intern_state}
  end

  @impl true
  def handle_call({:select,key},_from, intern_state) do
    {:reply, :ets.lookup(intern_state, key), intern_state}
  end

  @impl true
  def handle_call({:search,criteria},_from, intern_state) do
    list = criteria
    |> Enum.reduce([],fn {key,value},acc ->
       case key do
      "id" -> acc ++ :ets.match_object(intern_state, {value,:_})
      "key" -> acc ++ :ets.match_object(intern_state,{:_, value})
      _ -> acc
    end end)
    |> Enum.map(fn {t1,t2} -> %{"id"=>t1,"key"=>t2 } end)

    {:reply, {:ok,list}, intern_state}
  end

  #opt
  @impl true
  def handle_call({:select_all},_from, intern_state) do
    {:reply, :ets.tab2list(intern_state), intern_state}
  end

  @impl true
  def handle_call({:get_all_keys},_from, intern_state) do
    list = get_next_keys([],:ets.first(intern_state),intern_state)
    {:reply, list, intern_state}
  end

  @impl true
  def handle_call({:count},_from, intern_state) do
    count = get_count_keys(0,:ets.first(intern_state),intern_state)
    {:reply, count, intern_state}
  end

  defp get_count_keys(count,elem,ets_table) do
    case elem do
      :"$end_of_table" -> count
      _ -> get_count_keys(count + 1,:ets.next(ets_table,elem),ets_table)
    end
  end

  defp get_next_keys(li,elem,ets_table) do
    case elem do
      :"$end_of_table" -> li
      _ -> get_next_keys([elem|li],:ets.next(ets_table,elem),ets_table)
    end
  end

end
