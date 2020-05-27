defmodule Sleipnir.Data.GuildMessages do
  use GenServer

  def start_link(guild_id) do
    GenServer.start_link(__MODULE__, guild_id)
  end

  def init(guild_id) do
    {:ok, %{guild_id: guild_id, messages: %{}}}
  end

  def messages(pid) do
    GenServer.call(pid, :messages)
  end

  def add_message(pid, %{user_name: user_name}) do
    GenServer.call(pid, {:add_message, user_name})
  end

  def handle_call(:messages, _from, %{messages: messages} = state) do
    {:reply, messages, state}
  end

  def handle_call({:add_message, user_name}, _from, %{messages: messages} = state) do
    new_messages = Map.update(messages, user_name, 1, &(&1 + 1))
    {:reply, new_messages, %{state | messages: new_messages}}
  end
end
