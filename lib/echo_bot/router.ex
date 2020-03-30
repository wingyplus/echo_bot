defmodule EchoBot.Router do
  @line_secret_key Application.fetch_env!(:echo_bot, :line_secret_key)

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/callback" do
    handle_events(conn, validate_signature(conn))
  end

  defp validate_signature(conn) do
    {:ok, body, conn} = read_body(conn)

    valid =
      get_req_header(conn, "x-line-signature")
      |> List.first()
      |> LineBot.Signature.validate(
        body,
        @line_secret_key
      )

    {body, valid}
  end

  # Handle events in case valid signature.
  defp handle_events(conn, {_body, :ok}) do
    send_resp(conn, 200, Jason.encode!(%{}))
  end

  # Handle events in case invalid signature.
  defp handle_events(conn, {_, :invalid_signature}) do
    send_resp(conn, 400, Jason.encode!(%{"message" => "invalid signature"}))
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{"message" => "Not Found"}))
  end
end
