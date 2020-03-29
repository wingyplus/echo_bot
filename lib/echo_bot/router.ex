defmodule EchoBot.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/callback" do
    # TODO(wingyplus): validate signature
    handle_events(conn, validate_signature(conn))
  end

  defp validate_signature(conn) do
    get_req_header(conn, "x-line-signature")
    |> List.first()
    |> LineBot.Signature.validate()
  end

  # Handle events in case valid signature.
  defp handle_events(conn, :ok) do
    send_resp(conn, 200, Jason.encode!(%{}))
  end

  # Handle events in case invalid signature.
  defp handle_events(conn, :invalid_signature) do
    send_resp(conn, 400, Jason.encode!(%{"message" => "invalid signature"}))
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{"message" => "Not Found"}))
  end
end
