defimpl ExFSM.Machine.State, for: Map do
  def state_name(order), do: String.to_atom(order["status"]["state"])

  def set_state_name(order, name) do
  Kernel.get_and_update_in(order["status"]["state"], fn state -> {state, Atom.to_string(name)} end)
  end

  def handlers(order) do
    {res,_}=MyRules.apply_rules(order,[])
    res
  end
end

defmodule MyFSM.Paypal do
  use ExFSM

  deftrans init({:process_payment, []}, order) do
    IO.inspect("PAYPAL")
    {:next_state, :not_verified, order}
  end

  deftrans not_verified({:verfication, []}, order) do
    {:next_state, :finished, order}
  end


end


defmodule MyFSM.Stripe do
  use ExFSM

  deftrans init({:process_payment, []}, order) do
    IO.inspect("STRIPE")
    {:next_state, :not_verified, order}
  end

  deftrans not_verified({:verfication, []}, order) do
    {:next_state, :finished, order}
  end
end


defmodule MyFSM.Delivery do
  use ExFSM

  deftrans init({:process_payment, []}, order) do
    IO.inspect("processpayment ")
    {:next_state, :not_verified, order}
  end

  deftrans not_verified({:verfication, []}, order) do
    IO.inspect("verification")
    Process.sleep(3000)
    IO.inspect("done")
    {:next_state, :finished, order}
  end
end

defmodule MyRules do
  use Rulex
  defrule paypal_fsm(  %{"payment_method" => "paypal"}    = order, acc), do: {:ok, [MyFSM.Paypal   | acc]}
  defrule stripe_fsm(  %{"payment_method" => "stripe"}    = order, acc), do: {:ok, [MyFSM.Stripe   | acc]}
  defrule delivery_fsm(%{"payment_method" => _}  = order, acc), do: {:ok, [MyFSM.Delivery | acc]}
end
