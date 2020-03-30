defmodule EchoBot.Router do
  @line_secret_key Application.fetch_env!(:echo_bot, :line_secret_key)
  @line_access_token Application.fetch_env!(:echo_bot, :line_access_token)

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/callback" do
    {:ok, body, conn} = read_body(conn)

    {body, conn}
    |> validate_signature()
    |> handle_req()
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{"message" => "Not Found"}))
  end

  defp validate_signature({body, conn}) do
    valid =
      get_req_header(conn, "x-line-signature")
      |> List.first()
      |> LineBot.Signature.validate(
        body,
        @line_secret_key
      )

    {body, conn, valid}
  end

  # Handle events in case valid signature.
  defp handle_req({body, conn, :ok}) do
    req = Jason.decode!(body)
    handle_events(Map.get(req, "events"))
    send_resp(conn, 200, Jason.encode!(%{}))
  end

  # Handle events in case invalid signature.
  defp handle_req({_, conn, :invalid_signature}) do
    send_resp(conn, 400, Jason.encode!(%{"message" => "invalid signature"}))
  end

  defp handle_events(events) do
    Enum.map(events, &handle_event/1)
    |> replies()
    |> IO.inspect()
  end

  # Replies all of messages.
  #
  # Returns message that replies.
  defp replies([]), do: []

  defp replies([message | messages]) do
    reply(message) ++ replies(messages)
  end

  defp reply({:no_reply, _, _}) do
    []
  end

  defp reply({:reply, reply_token, message}) do
    req = %{
      "replyToken" => reply_token,
      "messages" => [message],
      "notificationDisabled" => false
    }

    {:ok, resp} =
      HTTPoison.post("https://api.line.me/v2/bot/message/reply", Jason.encode!(req), %{
        # TODO(wingyplus): refactor it!!
        "authorization" => "Bearer #{@line_access_token}",
        "content-type" => "application/json"
      })

    if resp.status_code != 200 do
      [{:error, resp.body}]
    else
      [{:ok, message}]
    end
  end

  defp handle_event(event) do
    reply_token = Map.get(event, "replyToken")

    case Map.get(event, "type") do
      "message" ->
        message = Map.get(event, "message")

        case Map.get(message, "type") do
          "text" ->
            {:reply, reply_token, text_message(Map.get(message, "text"))}

          "sticker" ->
            sticker_id = Map.get(message, "stickerId")

            {
              :reply,
              reply_token,
              text_message("sticker id is #{sticker_id}")
            }

          # not support for all others message at the moment.
          _ ->
            {:no_reply, "", %{}}
        end

      _ ->
        {:no_reply, "", %{}}
    end
  end

  defp text_message(text) do
    %{"type" => "text", "text" => text}
  end
end
