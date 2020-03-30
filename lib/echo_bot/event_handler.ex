defmodule EchoBot.EventHandler do
  @doc """
  Handle LINE webhook events.
  """
  def handle_events(events, line_access_token) do
    Enum.map(events, &handle_event/1)
    |> replies(line_access_token)
    |> IO.inspect()
  end

  defp replies(messages, line_access_token) do
    messages
    |> Stream.map(fn message -> reply(message, line_access_token) end)
    |> Enum.to_list()
  end

  defp reply({:no_reply, _, _}, _) do
    {:ok, ""}
  end

  defp reply({:reply, reply_token, message}, line_access_token) do
    req = %{
      "replyToken" => reply_token,
      "messages" => [message],
      "notificationDisabled" => false
    }

    {:ok, resp} =
      HTTPoison.post("https://api.line.me/v2/bot/message/reply", Jason.encode!(req), %{
        "authorization" => "Bearer #{line_access_token}",
        "content-type" => "application/json"
      })

    if resp.status_code != 200 do
      {:error, resp.body}
    else
      {:ok, message}
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
