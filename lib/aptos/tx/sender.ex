defmodule Aptos.Tx.Sender do
  defstruct [:address, :public_key, :private_key]

  @type t :: %__MODULE__{
          address: binary,
          public_key: binary,
          private_key: binary
        }

  def new(attrs) do
    struct(__MODULE__, attrs)
  end

  def new_from_hex(attrs) do
    attrs
    |> Enum.map(fn {k, v} ->
      {k, Aptos.Util.hex_to_binary(v)}
    end)
    |> new()
  end
end
