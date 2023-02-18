defmodule Aptos.Tx do
  alias BCS.DataType, as: T
  alias Aptos.BcsClient
  alias Aptos.Client.Result
  alias Aptos.Tx.Raw, as: RawTx
  alias Aptos.Tx.Auth
  alias Aptos.Tx.Payload
  alias Aptos.Tx.Sender

  @doc """
  Submit a transaction to the blockchain.

  You need to provide a `{payload, payload_layout}` tuple to make use of this function.

  An example to generate the `{payload, payload_layout}` tuple can be found in `Aptos.Contract.Coin.transfer/3`.

  Available options are:
  - `{:ttl, pos_integer()}`
  - `{:gas_price, pos_integer()}`
  - `{:max_gas, pos_integer()}`
  - `{:skip_testflight, boolean}`

  """
  @spec submit({Payload.t(), T.Choice.t()}, Sender.t(), keyword()) ::
          Result.t() | {:error, :testflight_failed, String.t()}
  def submit({payload, payload_layout}, %Sender{} = sender, opts \\ []) do
    ttl = Keyword.get(opts, :ttl, 600)
    gas_price = Keyword.get(opts, :gas_price, 100)
    max_gas = Keyword.get(opts, :max_gas, 20000)

    skip_testflight = Keyword.get(opts, :skip_testflight, false)

    if skip_testflight do
      payload
      |> RawTx.new(sender.address, gas_price, max_gas, ttl)
      |> bcs_encode_raw(payload_layout)
      |> Auth.Ed25519.append_signature(sender)
      |> BcsClient.submit_tx()
    else
      case payload
           |> RawTx.new(sender.address, gas_price, max_gas, ttl)
           |> bcs_encode_raw(payload_layout)
           |> Auth.Ed25519.append_signature(sender, :dummy)
           |> BcsClient.testflight_tx() do
        {:ok, _, [%{success: true} = resp | _]} ->
          gas_price = String.to_integer(resp.gas_unit_price)
          max_gas = String.to_integer(resp.max_gas_amount)

          payload
          |> RawTx.new(sender.address, gas_price, max_gas, ttl)
          |> bcs_encode_raw(payload_layout)
          |> Auth.Ed25519.append_signature(sender)
          |> BcsClient.submit_tx()

        {:ok, _, [%{success: false} = resp | _]} ->
          {:error, :testflight_failed, resp.vm_status}

        otherwise ->
          otherwise
      end
    end
  end

  defp bcs_encode_raw(raw_tx, payload_layout) do
    layout = RawTx.bcs_layout(payload_layout)
    BCS.encode(raw_tx, T.Struct.t(layout))
  end
end
