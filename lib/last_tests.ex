defmodule LastTests do
  def start(type, args) do
    IO.puts("LastTests.start")
    IO.inspect(binding())
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

  def websocket_handle({:text, content}, state) do
    IO.puts("BotAgentHandler.websocket_handle/2 {text, _}")
    IO.inspect(binding())
    {[{:text, String.reverse(content)}], state}
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
