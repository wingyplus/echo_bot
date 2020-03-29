defmodule LineBot.Signature do
  @doc """
  Validate LINE signature.

  Returns `:invalid_signature` when signature is invalid.
  """
  def validate(nil, _, _), do: :invalid_signature

  def validate(signature, body, channel_secret) do
    validate_signature(signature, hash(channel_secret, body))
  end

  defp validate_signature(signature, signature), do: :ok
  defp validate_signature(_, _), do: :invalid_signature

  defp hash(channel_secret, body) do
    :crypto.hmac(:sha256, channel_secret, body) |> Base.encode64()
  end
end
