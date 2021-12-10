defmodule MacroRIAK do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import MacroRIAK


      @bucketName "kbedu_orders"
      @schemaName "kbedu_orders_schema"
      @indexName "kbedu_orders_index"

      @code_my_error 404
      @content_my_error "ERROR 404"



    end
  end


  defmacro my_error(opts) do
    quote do
      code = unquote(opts[:code])
      content = unquote(opts[:content])
      @code_my_error if code == nil, do: 404, else: code
      @content_my_error if content == nil, do: "ERROR 404", else: content
    end
  end

end
