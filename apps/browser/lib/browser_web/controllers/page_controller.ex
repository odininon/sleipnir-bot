defmodule BrowserWeb.PageController do
  use BrowserWeb, :controller

  alias Sleipnir.Data.DiscordMessages

  def index(conn, _params) do
    report = DiscordMessages.messages()

    IO.inspect(report)
    render(conn, "index.html")
  end
end
