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

  def insertJsonToRiak(bucketName) do
    path = Path.join(File.cwd!,"ressources/orders_chunk0.json")
    {_ok,json} = File.read(path)
    map = Poison.Parser.parse!(json, %{})

    stream = Task.async_stream(map, JsonLoader, :test_func, [bucketName], max_concurrency: 10)
    |> Enum.map(fn {:ok, val} -> val end)
  end

  def test_func(json,bucketName) do

    {_ok,encodedJson} = Poison.encode(json)
    Riak.insertKeyValue(bucketName,Map.get(json,"id"),encodedJson)
    {:ok, "OK"}
  end
end
