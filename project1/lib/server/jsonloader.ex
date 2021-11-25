defmodule JsonLoader do
  def load_to_database(database , path)do
    {_ok,json} = File.read(path)
    map = Poison.Parser.parse!(json, %{})
    |> Enum.each(fn x -> Database.insert(database,Map.get(x,"id"),x) end)
  end
end
