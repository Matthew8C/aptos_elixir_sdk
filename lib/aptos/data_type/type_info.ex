defmodule Aptos.DataType.TypeInfo do
  @moduledoc """
  Convenience functions for dealing with [`TypeInfo`](https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-stdlib/doc/type_info.md) data type in Aptos.
  """

  alias Aptos.DataType.Parser
  import Aptos.Util, only: [binary_to_hex: 1]

  defstruct [:account_address, :module_name, :struct_name]

  @type t() :: %__MODULE__{
          account_address: binary,
          module_name: String.t(),
          struct_name: String.t()
        }

  @type payload() :: %{
          account_address: String.t(),
          module_name: String.t(),
          struct_name: String.t()
        }

  @spec from_string(String.t()) :: {:ok, t()} | :error
  def from_string(identifier) do
    case Parser.type_info(identifier) do
      {:ok, [{:type_info, type_info}], _, _, _, _} ->
        [account_address] = Keyword.fetch!(type_info, :account_address)
        [module_name] = Keyword.fetch!(type_info, :module_name)
        [struct_name] = Keyword.fetch!(type_info, :struct_name)

        {:ok,
         %__MODULE__{
           account_address: account_address,
           module_name: module_name,
           struct_name: struct_name
         }}

      _ ->
        :error
    end
  end

  @spec to_string(t()) :: String.t()
  def to_string(t) do
    binary_to_hex(t.account_address) <> "::" <> t.module_name <> t.struct_name
  end

  @spec to_payload(t()) :: payload()
  def(to_payload(t)) do
    %{
      account_address: binary_to_hex(t.account_address),
      module_name: binary_to_hex(t.module_name),
      struct_name: binary_to_hex(t.struct_name)
    }
  end

  @spec payload_from_string!(String.t()) :: payload()
  def payload_from_string!(identifier) do
    {:ok, t} = from_string(identifier)
    to_payload(t)
  end

  @spec key_type_payload :: String.t()
  def key_type_payload, do: "0x1::type_info::TypeInfo"
end
