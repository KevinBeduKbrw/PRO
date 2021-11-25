defmodule Server.JsonLoader do
  def load_to_database(database , path)do
    {_ok,json} = File.read(path)
    _map = Poison.Parser.parse!(json, %{})
    |> Enum.each(fn x -> Server.Database.insert(database,Map.get(x,"id"),x) end)
  end
end
