defmodule Aptos.Tx.TypeTag do
  @moduledoc """
  Implemented in accordance to:
  https://github.com/move-language/move/blob/0c9cb3a3adae184a23906f76972f9e025e4e0b7c/language/move-core/types/src/language_storage.rs#L25
  """

  alias BCS.DataType, as: T

  @type t() :: T.Choice.t()

  @spec t(T.t()) :: T.t()
  def t(type)

  def t(%T.Bool{} = _bool) do
    T.Choice.t(0)
  end

  def t(%T.UInt{bit_length: n} = _uint) do
    i = uint_index(n)
    T.Choice.t(i)
  end

  def t(%T.Address{} = _address) do
    T.Choice.t(4)
  end

  def t(%T.List{inner: type}) do
    t(type)
    |> T.List.t()
    |> T.Choice.t(6)
  end

  def t(%T.Struct{} = struct_tag) do
    T.Choice.t(struct_tag, 7)
  end

  # Helpers

  defp uint_index(8), do: 1
  defp uint_index(16), do: 8
  defp uint_index(32), do: 9
  defp uint_index(64), do: 2
  defp uint_index(128), do: 3
  defp uint_index(256), do: 10
end
