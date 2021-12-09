defmodule TransactionGenServer do
  use GenServer

  def start_link({initial_value,name}) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  @impl true
  def init(args) do
    {:ok, args}
  end

  def makePayment(id)do
      GenServer.call(__MODULE__,{:payment , id})
  end

  @impl true
  def handle_call({:payment,id},_from, intern_state) do
    order = Riak.getValueFromKey(id)
    |> Map.put("payment_method","idk")

    {:next_state, {old_state,updated_order}} = ExFSM.Machine.event(order, {:process_payment, []})
    timer.sleep(4000)
    {:next_state, {old_state,updated_order}} = ExFSM.Machine.event(updated_order, {:verfication, []})

    Riak.insertKeyValue(id,updated_order)
    order = Riak.getValueFromKey(id)

    {:reply, order, intern_state}
  end

  def stop()do
    GenServer.stop(__MODULE__)
  end

end
