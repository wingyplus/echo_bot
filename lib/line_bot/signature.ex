defmodule LineBot.Signature do
  @doc """
  Validate LINE signature.

  Returns `:invalid_signature` when signature is invalid.
  """
  def validate(nil, _, _), do: :invalid_signature

  def validate(signature, body, channel_secret) do
    validate(signature, sign_signature(channel_secret, body))
  end

  defp validate(signature, signature), do: :ok
  defp validate(_, _), do: :invalid_signature

  defp sign_signature(channel_secret, body) do
    :crypto.hmac(:sha256, channel_secret, body) |> Base.encode64()
  end
end
