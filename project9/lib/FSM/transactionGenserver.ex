defmodule TransactionGenServer do
  use GenServer

  @impl true
  def init(args) do
    {:ok, args}
  end

  def makePayment(id) do
    atomName = String.to_atom("TransactionGenServer_" <> id)
    process = GenServer.whereis(atomName)
    case process do
      nil ->
        GenServer.start_link(TransactionGenServer, [], name: atomName)
        GenServer.cast(atomName,{:payment , id})
      _   ->
        GenServer.cast(atomName,{:payment , id})
    end
  end

  @impl true
  def handle_cast({:payment,id}, intern_state) do
    order = Riak.getValueFromKey(id)
    |> Map.put("payment_method","idk")

    case ExFSM.Machine.State.state_name(order) do
      :finished ->  :action_unavailable
      _ ->
        {:next_state, {old_state,updated_order}} = ExFSM.Machine.event(order, {:process_payment, []})
        {:next_state, {old_state,updated_order}} = ExFSM.Machine.event(updated_order, {:verfication, []})

        Riak.insertKeyValue(id,Poison.encode!(updated_order))

    end

    {_,qn} = Process.info(self(), :message_queue_len)
    cond do
      qn > 0 -> {:noreply, "OK", intern_state}
      true   -> {:stop, :normal, intern_state}
    end
  end
end
