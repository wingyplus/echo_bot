defmodule EchoBot.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: EchoBot.Router, options: [port: 8080]}
    ]

    opts = [strategy: :one_for_one, name: EchoBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
