defmodule JsonLoader do
  def load_to_database(database , path)do
    {_ok,json} = File.read(path)
    map = Poison.Parser.parse!(json, %{})


    Enum.each(map,fn x ->
      z = Map.get(x,"custom")
      |> Map.get("customer")
      IO.inspect(z)
      GenServer.cast(Order_DB,{:insert, Map.get(x,"id"),x})
    end)

  end
end
