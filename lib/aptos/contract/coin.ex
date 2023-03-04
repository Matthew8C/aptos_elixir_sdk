defmodule Aptos.Contract.Coin do
  @moduledoc """
  Functions for working with `0x1::coin`.

  Implementations of this module also serve as examples for making use of this library when working with your own smart contracts.
  """

  alias Aptos.RestClient
  alias Aptos.Client.Result

  # Read

  @spec coin_info(binary, String.t()) :: Result.from_tesla()
  def coin_info(coin_addr, coin_id) do
    RestClient.show_account_resource(coin_addr, "0x1::coin::CoinInfo<#{coin_id}>")
  end

  @spec coin_store(binary, String.t()) :: Result.from_tesla()
  def coin_store(user_addr, coin_id) do
    RestClient.show_account_resource(user_addr, "0x1::coin::CoinStore<#{coin_id}>")
  end

  @spec coin_balance(binary, binary) ::
          {:ok, non_neg_integer()} | Result.err() | {:error, any()}
  def coin_balance(user_addr, coin_id) do
    with {:ok, _, %{data: data}} <- coin_store(user_addr, coin_id) do
      {:ok, String.to_integer(data.coin.value)}
    end
  end

  # Write

  alias Aptos.Tx.Payload
  alias Aptos.DataType.StructTag
  alias BCS.DataType, as: T

  @spec transfer(binary, non_neg_integer(), String.t()) :: {Payload.t(), T.Choice.t()}
  def transfer(recipient_addr, amount, coin_id) do
    {:ok, value, layout} = StructTag.from_string(coin_id)

    func_tag =
      StructTag.new(
        address: <<1>>,
        module: "coin",
        name: "transfer",
        type_arguments: [value]
      )

    t_args_layout = [layout]

    args = [recipient_addr, amount]
    args_layout = [T.Address.t(), T.UInt.t(64)]

    payload = Payload.EntryFunction.new(func_tag: func_tag, arguments: args)
    payload_layout = Payload.bcs_layout(:entry_function, t_args_layout, args_layout)

    {payload, payload_layout}
  end
end
