defmodule DataTest do
  use ExUnit.Case

  alias Sleipnir.Data.GuildMessages

  setup do
    {:ok, pid} = GuildMessages.start_link("354295072776257536")
    [pid: pid]
  end

  test "defaults to no messages", %{pid: pid} do
    assert GuildMessages.messages(pid) == %{}
  end

  test "when adding new message with unknown user", %{pid: pid} do
    assert GuildMessages.add_message(pid, %{user_name: "Freyadono", message: "What ever"}) == %{
             "Freyadono" => 1
           }
  end

  test "when adding new message with known user", %{pid: pid} do
    GuildMessages.add_message(pid, %{user_name: "Freyadono", message: "What ever"})

    assert GuildMessages.add_message(pid, %{user_name: "Freyadono", message: "What ever"}) == %{
             "Freyadono" => 2
           }
  end
end
