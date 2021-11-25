defmodule CustomGenserver do
  use GenServer

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def add(server,value) do
    GenServer.cast(server, {:add, value})
  end
  def sub(server,value) do
    GenServer.cast(server, {:sub, value})
  end
  def get(server) do
    GenServer.call(server,{:get})
  end

  @impl true
  def init(args) do
    IO.puts(args)
    {:ok, args}
  end

  @impl true
  def handle_cast({:add,value}, intern_state) do
    {:noreply, intern_state + value}
  end

  @impl true
  def handle_cast({:sub,value}, intern_state) do
    {:noreply, intern_state - value}
  end

  @impl true
  def handle_call({:get},_from, intern_state) do
    {:reply, intern_state, intern_state}
  end


end
