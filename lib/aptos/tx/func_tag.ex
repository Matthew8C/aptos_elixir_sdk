defmodule Aptos.Tx.FuncTag do
  @moduledoc """
  Mostly corresponds to the `StructTag` in Aptos terminology.
  """

  defstruct [:address, :module, :name, :type_arguments]

  alias BCS.DataType, as: T
  alias Aptos.Tx.TypeTag

  @type t() :: %__MODULE__{
          address: binary,
          module: String.t(),
          name: String.t(),
          type_arguments: list(T.t())
        }

  @doc """
  Makes a new BCS data type specification by providing the BCS type layout of the function's type arguments.
  """
  @spec t(list(T.t())) :: T.Struct.t()
  def t(t_args_layout \\ []) do
    type_tags = Enum.map(t_args_layout, &TypeTag.t/1)

    [
      address: T.Address.t(),
      module: T.Str.t(),
      name: T.Str.t(),
      type_arguments: T.List.t(type_tags)
    ]
    |> T.Struct.t()
  end

  @doc """
  Makes a new `FuncTag` data.
  """
  @spec new(keyword()) :: t()
  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  # Parse

  alias Aptos.Tx.FuncTag.Parser

  @doc """
  Parses an identifier such as `"0x1::aptos_coin::AptosCoin"`.

  A successful parsing gives `{:ok, func_tag, bcs_type}`.

  For example:

  `FuncTag.from_string("0x1::aptos_coin::AptosCoin")`
  gives
  ```
  {:ok,
    %FuncTag{
      address: <<1>>,
      module: "aptos_coin",
      name: "AptosCoin",
      type_arguments: []
    },
    %T.Struct{
      layout: [
        address: %T.Address{},
        module: %T.Str{},
        name: %T.Str{},
        type_arguments: %T.List{inner: []}
      ]
    }}
    ```

  """
  @spec from_string(binary) :: :error | {:ok, t(), T.Struct.t()}
  def from_string(identifier) do
    case Parser.type_tag(identifier) do
      {:ok, [res], _, _, _, _} ->
        value = from_parsed(res)
        layout = to_bcs_type(res)
        {:ok, value, layout}

      _ ->
        :error
    end
  end

  defp from_parsed({:func_tag, func_tag}) do
    [address] = Keyword.fetch!(func_tag, :address)
    module = Keyword.fetch!(func_tag, :module) |> List.to_string()
    name = Keyword.fetch!(func_tag, :name) |> List.to_string()

    type_arguments =
      func_tag
      |> Keyword.get(:type_arguments, [])
      |> Enum.map(&from_parsed/1)

    new(address: address, module: module, name: name, type_arguments: type_arguments)
  end

  defp from_parsed(others), do: others

  defp to_bcs_type("bool"), do: T.Bool.t()
  defp to_bcs_type("u8"), do: T.UInt.t(8)
  defp to_bcs_type("u16"), do: T.UInt.t(16)
  defp to_bcs_type("u32"), do: T.UInt.t(32)
  defp to_bcs_type("u64"), do: T.UInt.t(64)
  defp to_bcs_type("u128"), do: T.UInt.t(128)
  defp to_bcs_type("u256"), do: T.UInt.t(256)
  defp to_bcs_type("address"), do: T.Address.t()

  defp to_bcs_type({:vector, [type_arguments: [inner]]}) do
    to_bcs_type(inner)
    |> T.List.t()
  end

  defp to_bcs_type({:func_tag, func_tag}) do
    func_tag
    |> Keyword.get(:type_arguments, [])
    |> Enum.map(&to_bcs_type/1)
    |> t()
  end
end
