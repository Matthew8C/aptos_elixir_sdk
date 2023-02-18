defmodule Aptos.Tx.Raw do
  alias Aptos.Tx.Payload
  alias Aptos.RestClient
  alias BCS.DataType, as: T

  defstruct [
    :sender,
    :sequence_number,
    :payload,
    :max_gas_amount,
    :gas_unit_price,
    :expiration_timestamp_secs,
    :chain_id
  ]

  @type t() :: %__MODULE__{
          sender: binary,
          sequence_number: non_neg_integer(),
          payload: Payload.t(),
          max_gas_amount: non_neg_integer(),
          gas_unit_price: non_neg_integer(),
          expiration_timestamp_secs: non_neg_integer(),
          chain_id: non_neg_integer()
        }

  def bcs_layout(payload_layout) do
    [
      sender: T.Address.t(),
      sequence_number: T.UInt.t(64),
      payload: payload_layout,
      max_gas_amount: T.UInt.t(64),
      gas_unit_price: T.UInt.t(64),
      expiration_timestamp_secs: T.UInt.t(64),
      chain_id: T.UInt.t(8)
    ]
  end

  # Constructors

  def new() do
    struct(__MODULE__)
  end

  def new(payload, sender_addr, gas_price, max_gas, ttl) do
    new()
    |> put_sender(sender_addr)
    |> put_sequence_number()
    |> put_payload(payload)
    |> put_max_gas_amount(max_gas)
    |> put_gas_unit_price(gas_price)
    |> put_ttl(ttl)
    |> put_chain_id(Aptos.NetworkConfig.chain_id())
  end

  def put_sender(%__MODULE__{} = raw, sender) do
    Map.put(raw, :sender, sender)
  end

  def put_sequence_number(%__MODULE__{} = raw, n) do
    Map.put(raw, :sequence_number, n)
  end

  def put_sequence_number(%__MODULE__{sender: sender} = raw) do
    {:ok, _, account} = RestClient.show_account(sender)
    n = String.to_integer(account.sequence_number)
    put_sequence_number(raw, n)
  end

  def put_payload(%__MODULE__{} = raw, payload) do
    Map.put(raw, :payload, payload)
  end

  def put_max_gas_amount(%__MODULE__{} = raw, n) do
    Map.put(raw, :max_gas_amount, n)
  end

  def put_gas_unit_price(%__MODULE__{} = raw, n) do
    Map.put(raw, :gas_unit_price, n)
  end

  def put_ttl(%__MODULE__{} = raw, ttl) do
    timestamp = (DateTime.utc_now() |> DateTime.to_unix()) + ttl
    Map.put(raw, :expiration_timestamp_secs, timestamp)
  end

  def put_chain_id(%__MODULE__{} = raw, chain_id) do
    Map.put(raw, :chain_id, chain_id)
  end
end
