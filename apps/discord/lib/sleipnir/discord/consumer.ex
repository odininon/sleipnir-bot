defmodule Sleipnir.Discord.Consumer do
  use Nostrum.Consumer

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

      "Am I an idiot?" ->
        Api.create_reaction(msg.channel_id, msg.id, ":thumbsup:")

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

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    report = %{guild_id: msg.guild_id, message: msg.content, user_name: msg.author.username}
    DiscordMessages.add_message(report)
  end

  defp leader_to_string(messages) do
    Enum.map(messages, fn {user, num} -> "#{user} #{num}" end) |> Enum.join("\n")
  end

  defp messages_to_string(messages) do
    Enum.map(messages, fn {guild, messages} ->
      "Guild: #{guild}\nMessages:\n#{messages |> leader_to_string}"
    end)
    |> Enum.join("\n\n")
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
