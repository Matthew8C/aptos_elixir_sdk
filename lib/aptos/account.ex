defmodule Aptos.Account do

  @doc """
  Generates a new account
  """
  @spec new :: %{
          address: String.t(),
          auth_key: binary,
          private_key: binary,
          public_key: binary
        }
  def new() do
    {public_key, private_key} = :crypto.generate_key(:eddsa, :ed25519)
    auth_key = :crypto.hash(:sha3_256, public_key <> <<0>>)

    %{
      public_key: public_key,
      private_key: private_key,
      auth_key: auth_key,
      address: "0x" <> Base.encode16(auth_key, case: :lower)
    }
  end

  @doc """
  Signs some data with a private key
  """
  @spec sign(any, binary) :: binary
  def sign(data, private_key) do
    :crypto.sign(:eddsa, :none, data, [private_key, :ed25519])
  end
end
