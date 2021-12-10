defmodule TransactionGenServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(args) do
    {:ok, args}
  end

  def makePayment(id) do
    IO.inspect("CALL MAKEPAYMENT")
      GenServer.call(__MODULE__,{:payment , id})
  end

  @impl true
  def handle_call({:payment,id},_from, intern_state) do
    IO.inspect("HANDLE CALL")
    order = Riak.getValueFromKey(id)
    |> Map.put("payment_method","idk")

    case ExFSM.Machine.State.state_name(order) do
      :finished -> {:reply, :action_unavailable, intern_state}
      _ ->
        {:next_state, {old_state,updated_order}} = ExFSM.Machine.event(order, {:process_payment, []})
        {:next_state, {old_state,updated_order}} = ExFSM.Machine.event(updated_order, {:verfication, []})

        Riak.insertKeyValue(id,Poison.encode!(updated_order))
        order = Riak.getValueFromKey(id)

        {:reply, order, intern_state}
    end


  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

end
