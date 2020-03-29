defmodule EchoBot.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/callback" do
    # TODO(wingyplus): validate signature
    send_resp(conn, 200, Jason.encode!(%{}))
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{"message" => "Not Found"}))
  end
end
