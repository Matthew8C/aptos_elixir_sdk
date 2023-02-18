defmodule Aptos.BcsClient do
  @moduledoc """
  BCS endpoint for submitting and testflighting transactions
  """

  @endpoint Aptos.NetworkConfig.node_url()

  use Tesla, docs: false

  plug Tesla.Middleware.BaseUrl, @endpoint
  plug Tesla.Middleware.Headers, [{"Content-Type", "application/x.aptos.signed_transaction+bcs"}]
  plug Tesla.Middleware.DecodeJson, engine_opts: [keys: :atoms]
  plug Tesla.Middleware.Timeout, timeout: 15_000

  alias Aptos.Client.Result

  @doc """
  Submits a transaction.
  """
  @spec submit_tx(binary) :: Result.from_tesla()
  def submit_tx(signed_bcs) do
    post("/transactions", signed_bcs)
    |> Result.from_tesla()
  end

  @doc """
  Testflight (simulate) a transaction.
  """
  @spec testflight_tx(binary) :: Result.from_tesla()
  def testflight_tx(dummy_signed_bcs) do
    query = [
      estimate_gas_unit_price: true,
      estimate_max_gas_amount: true,
      estimate_prioritized_gas_unit_price: false
    ]

    post("/transactions/simulate", dummy_signed_bcs, query: query)
    |> Result.from_tesla()
  end
end
