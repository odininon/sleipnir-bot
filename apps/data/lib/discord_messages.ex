defmodule Sleipnir.Data.DiscordMessages do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{guilds: %{}}}
  end

  def messages(), do: messages(__MODULE__)

  def messages(pid) do
    GenServer.call(pid, :messages)
  end

  def add_message(message), do: add_message(__MODULE__, message)

  def add_message(_pid, %{guild_id: nil}), do: :noop

  def add_message(pid, message) do
    GenServer.call(pid, {:add_message, message})
  end

  def handle_call(
        {:add_message, %{guild_id: guild_id} = message},
        _from,
        %{guilds: guilds} = state
      ) do
    guild_pid =
      case Map.get(guilds, guild_id, nil) do
        nil ->
          {:ok, pid} = Sleipnir.Data.GuildMessages.start_link(guild_id)
          pid

        pid ->
          pid
      end

    new_state = %{state | guilds: Map.update(guilds, guild_id, guild_pid, &Function.identity/1)}

    {:reply, Sleipnir.Data.GuildMessages.add_message(guild_pid, message), new_state}
  end

  def handle_call(:messages, _from, %{guilds: guilds} = state) do
    messages =
      Enum.map(guilds, fn {guild_id, pid} ->
        %{guild_id => Sleipnir.Data.GuildMessages.messages(pid)}
      end)

    {:reply, Enum.reduce(messages, %{}, &Enum.into(&1, &2)), state}
  end
end
