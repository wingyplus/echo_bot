defmodule LineBot.Signature do
  def validate(nil) do
    :invalid_signature
  end

  def validate(_signature) do
    :ok
  end
end
