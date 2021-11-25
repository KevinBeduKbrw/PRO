defmodule Server.TheCreator do

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Server.TheCreator
      import Plug.Conn

      @pathKV %{}
      @tests []

      @code_my_error 404
      @content_my_error "ERROR 404"

      @before_compile Server.TheCreator

    end
  end

  defmacro __before_compile__(_env) do
    quote do


      def init(opts) do
        opts
      end

      def call(conn, _opts) do
        res = Map.get(@pathKV,conn.request_path)
        put_resp_content_type(conn,"text/plain")

        case res do
          nil -> send_resp(conn,@code_my_error,@content_my_error)
          {b1,b2} -> send_resp(conn,b1,b2)
        end
      end
    end
  end      #{ok,pid} = Server.Serv_supervisor.start_link([])
  #[{_, reg, _, _}] = Supervisor.which_children(pid)

  #@pid_SV pid
  #@pid_DB reg

  @pid_SV "pid"
  @pid_DB "reg"

  #IO.puts("SUPERVISOR : ")
  #IO.inspect(@)
  #IO.puts("DATABASE : ")
  #IO.inspect(reg)



  defmacro my_error(opts) do
    quote do
      code = unquote(opts[:code])
      content = unquote(opts[:content])
      @code_my_error if code == nil, do: 404, else: code
      @content_my_error if content == nil, do: "ERROR 404", else: content
    end
  end

  defmacro my_get(route,do: {_b1,_b2} = block) do
    quote do
      @tests [unquote(route) | @tests]
      @pathKV Map.put(@pathKV,unquote(route),unquote(block))
    end
  end

end
