defmodule Aptos.Client.Result.Header do
  @moduledoc false

  @integer_fields ~w(block-height chain-id epoch ledger-oldest-version ledger-version oldest-block-height)

  def cast(value, identifier) when identifier in @integer_fields do
    String.to_integer(value)
  end

  def cast(value, "ledger-timestampusec") do
    String.to_integer(value)
    |> DateTime.from_unix!(:microsecond)
  end

  def cast(value, _identifier), do: value

  def underscore_key(key) do
    key
    |> String.replace("-", "_")
    |> String.to_atom()
  end
end
