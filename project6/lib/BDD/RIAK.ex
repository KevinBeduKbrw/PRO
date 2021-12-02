defmodule Riak do
  def url, do: "https://kbrw-sb-tutoex-riak-gateway.kbrw.fr"

  def auth_header do
    username = "sophomore"
    password = "jlessthan3tutoex"
    auth = :base64.encode_to_string("#{username}:#{password}")
    [{'authorization', 'Basic #{auth}'}]
  end

  def start do
    bucketName = "kbedu_orders"
    schemaName = "kbedu_orders_schema"
    indexName  = "kbedu_orders_index"
    #Riak.insertKeyValue(bucketName,"122221","someKey")
    #Riak.insertKeyValue(bucketName,"12","xxxxx")
    Riak.insertKeyValue(bucketName,"46","kabarawa")

    Riak.getAllBuckets()
    |> print
    #Riak.emptyBucket(bucketName)
    #Riak.getAllIndex()
    #Riak.createIndex(indexName,schemaName)
    #Riak.uploadSchema(schemaName,"ressources/order_schema.xml")
    #Riak.getSchema(schemaName)
    #IO.inspect(Riak.getAllBuckets)
    #Riak.insertKeyValue(bucketName,"122221","someKey")
    #Riak.getAllKeys(bucketName)
    #|> Enum.each(fn key -> Riak.getValueFromKey(bucketName,key) end)

    #Riak.deleteKey(bucketName,"122221")
  end

  defp print(var) when is_map(var),  do: var |>  Enum.each(fn {v,x} -> IO.inspect(v <> " : " <> x) end)
  defp print(var) when is_list(var), do: var |>  Enum.each(fn x -> IO.inspect(x) end)


  def getAllBuckets do
    _msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,{'#{Riak.url()}/buckets?buckets=true', Riak.auth_header()},[],[])
    {_,map} = Poison.decode(body)

    Map.get(map,"buckets")
  end

  def getAllKeys(bucketName) do
    _msg = {:ok,{{_,200,_message},_headers,body}} = :httpc.request(:get,{'#{Riak.url()}/buckets/#{bucketName}/keys?keys=true', Riak.auth_header()},[],[])
    {_,map} = Poison.decode(body)

    Map.get(map,"keys")
  end

  def getAllIndexes do
    _req = :httpc.request(:get,{'#{Riak.url()}/search/index', Riak.auth_header()},[],[])
  end

  def getSchema(schemaName) do
    _req = :httpc.request(:get,{'#{Riak.url()}/search/schema/#{schemaName}', Riak.auth_header()},[],[])
  end

  def getValueFromKey(bucketName,key) do
    _msg = {:ok,{{_,200,_message},_headers,body}}  = :httpc.request(:get,{'#{Riak.url()}/buckets/#{bucketName}/keys/#{key}', Riak.auth_header()},[],[])
    IO.puts(key <> " : " <> List.to_string(body))
  end


  def insertKeyValue(bucketName,key,value) do
    _req = :httpc.request(:put,{'#{Riak.url()}/buckets/#{bucketName}/keys/#{key}', Riak.auth_header(),'application/json',value},[],[])
  end

  def uploadSchema(schemaName,schemaPath) do
    {_ok, file} = File.read(schemaPath)
    _req = :httpc.request(:put,{'#{Riak.url()}/search/schema/#{schemaName}', Riak.auth_header(),'application/xml',file},[],[])
  end

  def createIndex(indexName,schemaName) do
    {_ok,data} = Poison.encode(%{"schema"=>schemaName})
    _req = :httpc.request(:put,{'#{Riak.url()}/search/index/#{indexName}', Riak.auth_header(),'application/json',data},[],[])
  end

  def setIndexToBucket(bucketName,indexName,value) do
    _req = :httpc.request(:get,{'#{Riak.url()}/buckets/#{bucketName}/index/#{indexName}/#{value}', Riak.auth_header()},[],[])
  end

  def setIndexToBucket(bucketName,indexName,startValue,endValue) do
    _req = :httpc.request(:get,{'#{Riak.url()}/buckets/#{bucketName}/index/#{indexName}/#{startValue}/#{endValue}', Riak.auth_header()},[],[])
  end


  def deleteKey(bucketName,key) do
    _req = :httpc.request(:delete,{'#{Riak.url()}/buckets/#{bucketName}/keys/#{key}', Riak.auth_header()},[],[])
  end

  def emptyBucket(bucketName) do
    Riak.getAllKeys(bucketName)
    |> Enum.each(fn x -> Riak.deleteKey(bucketName,x) end )
  end

  def deleteBucket(bucketName) do
    Riak.emptyBucket(bucketName)
  end


end
