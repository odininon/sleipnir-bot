defmodule DiscordMessagesTests do
  use ExUnit.Case

  alias Sleipnir.Data.DiscordMessages

  setup do
    {:ok, pid} = DiscordMessages.start_link()
    [pid: pid]
  end

  test "defaults to no messages", %{pid: pid} do
    assert DiscordMessages.messages(pid) == %{}
  end

  test "add message to unknown guild", %{pid: pid} do
    assert DiscordMessages.add_message(pid, %{
             user_name: "Freyadono",
             message: "Doesn't matter",
             guild_id: "354295072776257536"
           }) == %{"Freyadono" => 1}
  end

  test "add message to known guild and known user", %{pid: pid} do
    DiscordMessages.add_message(pid, %{
      user_name: "Freyadono",
      message: "Doesn't matter",
      guild_id: "354295072776257536"
    })

    assert DiscordMessages.add_message(pid, %{
             user_name: "Freyadono",
             message: "Doesn't matter",
             guild_id: "354295072776257536"
           }) == %{"Freyadono" => 2}
  end

  test "get all messages", %{pid: pid} do
    DiscordMessages.add_message(pid, %{
      user_name: "Freyadono",
      message: "Doesn't matter",
      guild_id: "354295072776257536"
    })

    DiscordMessages.add_message(pid, %{
      user_name: "Freyadono",
      message: "Doesn't matter",
      guild_id: "354295072776257536"
    })

    assert DiscordMessages.messages(pid) == %{
             "354295072776257536" => %{"Freyadono" => 2}
           }
  end
end
