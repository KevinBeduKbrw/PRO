defmodule MyGenericServer do
  def loop({callback_module, server_state}) do
    receive do
      {:cast,value}->
        loop({callback_module,callback_module.handle_cast(value,server_state)})
      {:call,value,pid}->
        {_am,amount} = callback_module.handle_call(value,server_state)
        send(pid,amount)
        loop({callback_module,server_state})
      _ ->
        loop({callback_module,server_state})
    end
  end

  def cast(process_pid, request) do
    send(process_pid,{:cast,request})
    :ok
  end

  def call(process_pid, request) do
    send(process_pid,{:call,request,self()})
     receive do request-> request end
  end

  def start_link(callback_module,server_initiale_state) do
    Task.start_link(fn -> loop({callback_module,server_initiale_state}) end)
  end



end
