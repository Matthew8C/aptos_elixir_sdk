defmodule Aptos.NetworkConfig do
  @moduledoc false

  @config Application.compile_env(:aptos, :network)

  @spec node_url :: String.t()
  def node_url() do
    @config[:node_url]
  end

  @spec faucet_url :: String.t() | nil
  def faucet_url() do
    @config[:faucet_url]
  end

  @spec chain_id :: pos_integer()
  def chain_id() do
    @config[:chain_id]
  end
end
