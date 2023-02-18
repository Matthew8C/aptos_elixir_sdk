defmodule Aptos.FaucetClient do
  @moduledoc """
  Faucet client.
  Only applicable on Devnet or Testnet.
  """

  @endpoint Aptos.NetworkConfig.faucet_url()

  use Tesla, docs: false

  plug Tesla.Middleware.BaseUrl, @endpoint
  plug Tesla.Middleware.JSON, engine_opts: [keys: :atoms]
  plug Tesla.Middleware.Timeout, timeout: 15_000

  alias Aptos.Client.Result

  @doc """
  Funds an account with a specific amount of APT.
  """
  @spec fund_account(binary, non_neg_integer()) :: Result.from_tesla()
  def fund_account(address, amount) do
    address = "0x" <> Base.encode16(address, case: :lower)

    post("/mint", %{}, query: %{address: address, amount: amount})
    |> Result.from_tesla()
  end
end
