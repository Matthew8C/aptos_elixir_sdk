defmodule Aptos.Util do
  @spec binary_to_hex(binary) :: String.t()
  def binary_to_hex(bin) do
    "0x" <> Base.encode16(bin, case: :lower)
  end

  @spec binary_to_address(binary) :: String.t()
  def binary_to_address(bin) do
    "0x" <> String.trim_leading(Base.encode16(bin, case: :lower), "0")
  end

  @spec hex_to_binary(String.t()) :: binary
  def hex_to_binary("0x" <> hex) do
    hex_to_binary(hex)
  end

  def hex_to_binary(hex) when rem(byte_size(hex), 2) == 1 do
    hex_to_binary("0" <> hex)
  end

  def hex_to_binary(hex) do
    Base.decode16!(hex, case: :lower)
  end
end
