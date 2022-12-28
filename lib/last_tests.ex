defmodule LastTests do
  def start(type, args) do
    IO.puts("LastTests.start")
    IO.inspect(binding())
    KV.start()
    dispatch = :cowboy_router.compile([
      {'localhost', 
        [
          { "/ws/ui/[...]", UIAgentHandler, [] },
          { "/ws/agents/[...]", BotAgentHandler, [] }
        ]
      },
    ])
    {:ok, _} = :cowboy.start_clear(
      :http, [{:port, 8080}],
      %{env: %{ dispatch: dispatch } }
    )
    
  end
end

defmodule AgentIntroduction do
  @derive [Poison.Encoder]
  defstruct [:version, :type, :capabilities, :specializations]
end

defmodule UIAgentHandler do
  @behaviour :cowboy_websocket

  def init(req, state) do
    IO.puts("UIAgentHandler.init")
    IO.inspect(binding())
    # ???
    {:cowboy_websocket, req, state}
  end

  def terminate(_reason, _req, _state) do
    IO.puts("UIAgentHandler.terminate")
    IO.inspect(binding())
    :ok
  end

  def websocket_init(state) do
    IO.puts("UIAgentHandler.websocket_init")
    IO.inspect(binding())
    {[{:text, "Meow"}, {:text, "Pouip"}], state}
  end

  def websocket_info({:log, log_message}, state) do
    IO.puts("UIAgentHandler.websocket_info")
    IO.inspect(binding())
    {[{:text, log_message}], state}
  end

  def websocket_info(_info, state) do
    IO.puts("UIAgentHandler.websocket_info/2 {_info, state}")
    IO.inspect(binding())
    {:ok, state}
  end

  def websocket_handle({:text, content}, state) do
    IO.puts("UIAgentHandler.websocket_handle/2 {text, _}")
    IO.inspect(binding())
    {[{:text, String.reverse(content)}], state}
  end

  def websocket_handle(frame, state) do
    IO.puts("UIAgentHandler.websocket_handle/2 {frame, state}")
    IO.inspect(binding())
    {:ok, state}
  end

end

defmodule KV do

  @kv_module_name :kv

  defp receive_value do
    receive do
      {:ok, {:kv, :get, _key, value}} -> {:ok, value}
      {:ok, {:kv, :set, key, value}} -> {:ok, key, value}
    after
      # In milliseconds
      1_000 -> {:error, "The key value process is not responding..."}
    end
  end

  def set(key, value) do
    send(@kv_module_name, {:set, self(), key, value})
    receive_value()
  end

  def get(key) do
    send(@kv_module_name, {:get, self(), key})
    receive_value()
  end

  def start() do
    Process.register(spawn(fn -> main_handler(%{}) end), :kv)
  end

  defp main_handler(values) do
    
    receive do
      {:get, caller, key} -> 
        send caller, {:ok, {:kv, :get, key, Map.get(values, key)}}
        main_handler(values)
      {:set, caller, key, value} ->
        new_values = Map.put(values, key, value)
        send caller, {:ok, {:kv, :set, key, Map.get(new_values, key)}} 
        main_handler(new_values)
      _ ->
        IO.puts("KV : Received a weird message")
        IO.puts(binding())
        main_handler(values)
    end
  end
end

defmodule BotAgentHandler do
  @behaviour :cowboy_websocket

  def init(req, state) do
    IO.puts("BotAgentHandler.init")
    IO.inspect(binding())
    # ???
    {:cowboy_websocket, req, state}
  end

  def terminate(_reason, _req, _state) do
    IO.puts("BotAgentHandler.terminate")
    IO.inspect(binding())
    :ok
  end

  def websocket_init(state) do
    IO.puts("BotAgentHandler.websocket_init")
    IO.inspect(binding())
    {[{:text, "Meow"}, {:text, "Pouip"}], state}
  end

  def websocket_info({:log, log_message}, state) do
    IO.puts("BotAgentHandler.websocket_info")
    IO.inspect(binding())
    {[{:text, log_message}], state}
  end

  def websocket_info(_info, state) do
    IO.puts("BotAgentHandler.websocket_info/2 {_info, state}")
    IO.inspect(binding())
    {:ok, state}
  end

  def handle_agent_message(%{"type" => "@AgentIntroduction", "version" => 1, "capabilities" => capabilities}) do
    IO.puts(~s(BotAgentHandler.handle_agent_message {"type" => "@AgentIntroduction"}) )
    IO.inspect(binding())
    {:ok, "Pouip Pouip abord, agent version 1. I see that you can do : #{capabilities} !"}
  end

  def handle_agent_message(_decoded) do
    IO.puts("BotAgentHandler.handle_agent_message")
    IO.inspect(binding())
    {:error, "Invalid message"}
  end

  def websocket_handle({:text, content}, state) do
    IO.puts("BotAgentHandler.websocket_handle/2 {text, _}")
    IO.inspect(binding())
    response = try do
       case Poison.decode(content) do
        {:ok, decoded_content} -> handle_agent_message(decoded_content)
        {:error, reason} -> {:error, "Invalid JSON : #{reason}"}
      end
    rescue
      e ->
        {:error, Exception.format(:error, e, __STACKTRACE__)}
    end
    {[{:text, Poison.encode!(Map.new([response]))}], state}
  end

  def websocket_handle(frame, state) do
    IO.puts("BotAgentHandler.websocket_handle/2 {frame, state}")
    IO.inspect(binding())
    {:ok, state}
  end
end

defmodule MyySigils do
  def sigil_i(string, []), do: String.to_integer(string)
  def sigil_i(string, [?n]), do: -String.to_integer(string)
end
