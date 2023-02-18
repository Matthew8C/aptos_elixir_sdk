defmodule Aptos.Tx.Auth do
  @moduledoc false

  defmodule Ed25519 do
    defstruct [:public_key, :signature]

    @type t() :: %__MODULE__{
            public_key: binary,
            signature: binary
          }

    alias BCS.DataType, as: T
    alias Aptos.Tx.Sender

    @spec bcs_layout :: keyword(T.t())
    def bcs_layout() do
      [
        public_key: T.Binary.t(),
        signature: T.Binary.t()
      ]
    end

    @spec new(binary, Sender.t()) :: t()
    def new(bcs_encoded_raw_tx, %Sender{} = sender) do
      signature = sign_bcs_encoded(bcs_encoded_raw_tx, sender.private_key)
      struct(__MODULE__, public_key: sender.public_key, signature: signature)
    end

    @spec new(any, Sender.t(), :dummy) :: t()
    def new(_, %Sender{} = sender, :dummy) do
      struct(__MODULE__, public_key: sender.public_key, signature: <<0::512>>)
    end

    @spec append_signature(binary, Sender.t()) :: binary
    def append_signature(bcs_encoded_raw_tx, %Sender{} = sender) do
      bcs_encoded_raw_tx <>
        (bcs_encoded_raw_tx
         |> new(sender)
         |> encode_bcs())
    end

    @spec append_signature(binary, Sender.t(), :dummy) :: binary
    def append_signature(bcs_encoded_raw_tx, %Sender{} = sender, :dummy) do
      bcs_encoded_raw_tx <> encode_bcs(new(<<>>, sender))
    end

    @spec encode_bcs(t()) :: binary
    def encode_bcs(%__MODULE__{} = auth) do
      layout = bcs_layout() |> T.Struct.t() |> T.Choice.t(0)
      BCS.encode(auth, layout)
    end

    @prefix_bytes :crypto.hash(:sha3_256, "APTOS::RawTransaction")

    @spec sign_bcs_encoded(binary, binary) :: binary
    def sign_bcs_encoded(encoded, private_key) do
      :crypto.sign(:eddsa, :none, @prefix_bytes <> encoded, [private_key, :ed25519])
    end
  end

  defmodule MultiEd25519 do
    @moduledoc false

    defstruct [:public_key, :signature]

    @type t() :: %__MODULE__{
            public_key: binary,
            signature: list(binary)
          }

    alias BCS.DataType, as: T

    def bcs_layout() do
      [
        public_key: T.Binary.t(),
        signature: T.List.t(T.Binary.t())
      ]
    end
  end

  defmodule MultiAgent do
    @moduledoc false

    defstruct [:sender, :secondary_signer_addresses, :secondary_signers]

    @type t() :: %__MODULE__{
            sender: map(),
            secondary_signer_addresses: list(binary),
            secondary_signers: list(map())
          }
  end
end
