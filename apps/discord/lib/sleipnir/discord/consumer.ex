defmodule Sleipnir.Discord.Consumer do
  use Nostrum.Consumer
  require Logger

  alias Nostrum.Api
  alias Sleipnir.Data.DiscordMessages

  @mod_channel_id 729_068_932_698_341_509

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, %{channel_id: @mod_channel_id} = msg, _ws_state}) do
    report = %{guild_id: msg.guild_id, message: msg.content, user_name: msg.author.username}
    DiscordMessages.add_message(report)

    case msg.content do
      "ping!" ->
        Api.create_message(@mod_channel_id,
          content: "pong!",
          message_reference: %{message_id: msg.id}
        )

      "report!" ->
        report = DiscordMessages.messages() |> messages_to_string

        Api.create_message(@mod_channel_id,
          content: "Report:\n#{report}",
          message_reference: %{message_id: msg.id}
        )

      _ ->
        :noop
    end
  end

  defp sort_by_count(messages) do
    messages |> Map.to_list() |> Enum.sort(fn {_k1, val1}, {_k2, val2} -> val1 >= val2 end)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    report = %{guild_id: msg.guild_id, message: msg.content, user_name: msg.author.username}
    DiscordMessages.add_message(report)
  end

  defp leader_to_string(messages) do
    Enum.map(messages, fn {user, num} -> "#{user} #{num}" end) |> Enum.join("\n")
  end

  defp messages_to_string(messages) do
    Enum.map(messages, fn {guild_id, messages} ->
      guild_name =
        case Nostrum.Cache.GuildCache.get(guild_id) do
          {:ok, guild} -> guild.name
          {:error, _reason} -> guild_id
        end

      "Guild: #{guild_name}\nMessages:\n#{messages |> sort_by_count |> leader_to_string}"
    end)
    |> Enum.join("\n\n")
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
