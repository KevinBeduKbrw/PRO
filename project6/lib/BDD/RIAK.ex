defmodule Riak do
  use MacroRIAK

  def url, do: "https://kbrw-sb-tutoex-riak-gateway.kbrw.fr"

  def auth_header do
    username = "sophomore"
    password = "jlessthan3tutoex"
    auth = :base64.encode_to_string("#{username}:#{password}")
    [{'authorization', 'Basic #{auth}'}]
  end

  def start do
    #Riak.insertKeyValue("122221","someKey")
    #Riak.insertKeyValue("12","xxxxx")
    #Riak.insertKeyValue("46","kabarawa")
    #JsonLoader.insertJsonToRiak()
    msg = {:ok,{{_,200,_message},headers,body}} = Riak.search("id:*")
    #Riak.insertPropsToBucket(%{"search_index"=> @indexName })
    #Riak.getIndex()
    #Riak.getSchema()

    #Riak.getBucket()
    #Riak.setIndexToBucket("id")
    #Riak.emptyBucket()

    #Process.sleep(1000)
    #Riak.emptyBucket()
    #Riak.search("id:*")
    #Riak.getValueFromKey("nat_order000147705")

    #Riak.emptyBucket()
    #Riak.getAllIndex()
    #Riak.createIndex()
    #Riak.uploadSchema("ressources/order_schema.xml")
    #Riak.getSchema()
    #IO.inspect(Riak.getAllBuckets)
    #Riak.insertKeyValue("122221","someKey")
    #Riak.getAllKeys()
    #|> Enum.each(fn key -> Riak.getValueFromKey(key) end)

    #Riak.deleteKey("122221")
  end

  defp print(var) when is_binary(var), do: IO.inspect(var)
  defp print(var) when is_map(var),  do: var |>  Enum.each(fn {v,x} -> IO.inspect(v <> " : " <> x) end)
  defp print(var) when is_list(var), do: var |>  Enum.each(fn x -> IO.inspect(x) end)

  def search(query, page \\ 0, rows \\ 30, sort \\ "creation_date_int") do
    page = page * rows
    IO.inspect(query)
    IO.inspect(rows)
    IO.inspect(page)
    msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,
          {'#{Riak.url()}/search/query/#{@indexName}/?wt=json&q=#{query}&rows=#{rows}&start=#{ page}&sort=#{sort}+desc', Riak.auth_header()},
          [],[])

    res = body
    |> to_string
    |> Poison.decode!
    |> Map.get("response")
    |> Map.get("docs")
    |> Enum.map(fn x -> IO.inspect(Map.get(x,"creation_date_int")) end)

    msg

    #IO.inspect(map)
  end

  def getAllBuckets do
    _msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,{'#{Riak.url()}/buckets?buckets=true', Riak.auth_header()},[],[])
    {_,map} = Poison.decode(body)

    Map.get(map,"buckets")
  end

  def getAllKeys() do
    _msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,{'#{Riak.url()}/buckets/#{@bucketName}/keys?keys=true', Riak.auth_header()},[],[])
    {_,map} = Poison.decode(body)

    Map.get(map,"keys")
  end

  def getAllIndexes do
    _msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,{'#{Riak.url()}/search/index', Riak.auth_header()},[],[])
    {_,map} = Poison.decode(body)
    map
  end

  def getIndex() do
    _msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,{'#{Riak.url()}/search/index/#{@indexName}', Riak.auth_header()},[],[])
    {_,map} = Poison.decode(body)
    IO.inspect(map)
    map
  end

  def getSchema() do
    msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,{'#{Riak.url()}/search/schema/#{@schemaName}', Riak.auth_header()},[],[])
    to_string(body)
  end

  def getBucket() do
    _msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,{'#{Riak.url()}/buckets/#{@bucketName}/props', Riak.auth_header()},[],[])
    {_,map} = Poison.decode(body)
    IO.inspect(map)
    map
  end

  def getValueFromKey(key) do
    msg = {:ok,{{_,errorCode,_message},_headers,body}}  = :httpc.request(:get,{'#{Riak.url()}/buckets/#{@bucketName}/keys/#{key}', Riak.auth_header()},[],[])
    msg

  end


  def insertKeyValue(key,value,dataType \\ 'application/json' ) do
    _req = :httpc.request(:put,{'#{Riak.url()}/buckets/#{@bucketName}/keys/#{key}', Riak.auth_header(),dataType,value},[],[])
  end

  def insertPropsToBucket(mapProps \\ %{}) do
    {_ok,encodedProps}= Poison.encode(%{"props" => mapProps})
    req = :httpc.request(:put,{'#{Riak.url()}/buckets/#{@bucketName}/props', Riak.auth_header(),'application/json',encodedProps},[],[])
    IO.inspect(req)
  end

  def uploadSchema(schemaPath) do
    {_ok, file} = File.read(schemaPath)
    _req = :httpc.request(:put,{'#{Riak.url()}/search/schema/#{@schemaName}', Riak.auth_header(),'application/xml',file},[],[])
  end

  def createIndex() do
    {_ok,data} = Poison.encode(%{"schema"=>@schemaName})
    _req = :httpc.request(:put,{'#{Riak.url()}/search/index/#{@indexName}', Riak.auth_header(),'application/json',data},[],[])
  end

  def setIndexToBucket(value) do
    req = :httpc.request(:get,{'#{Riak.url()}/buckets/#{@bucketName}/index/#{@indexName}/#{value}', Riak.auth_header()},[],[])
    IO.inspect(req)
  end

  def setIndexToBucket(startValue,endValue) do
    req = :httpc.request(:get,{'#{Riak.url()}/buckets/#{@bucketName}/index/#{@indexName}/#{startValue}/#{endValue}', Riak.auth_header()},[],[])
    IO.inspect(req)
  end


  def deleteKey(key) do
    _req = :httpc.request(:delete,{'#{Riak.url()}/buckets/#{@bucketName}/keys/#{key}', Riak.auth_header()},[],[])
  end

  def emptyBucket() do
    Riak.getAllKeys()
    |> Enum.each(fn x -> Riak.deleteKey(x) end )
  end

  def deleteBucket() do
    Riak.emptyBucket()
  end


end
