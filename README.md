# Aptos SDK for Elixir

A toolkit for working with Aptos in Elixir.

This library is still a work-in-progress, but is already quite usable at this state.

Bug reports and pull requests are hugely welcomed.

## Installation

The package can be installed by adding `aptos` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:aptos, "~> 0.1.0"},
    {:bcs, "~> 0.1.1", hex: :ex_bcs}
  ]
end
```

You need to provide a network configuration, for example:

```elixir
# Configures Aptos
config :aptos, :network,
  node_url: "https://fullnode.devnet.aptoslabs.com/v1",
  faucet_url: "https://faucet.devnet.aptoslabs.com",
  chain_id: 53
```

API clients are using `Tesla` with `Finch` as the HTTP client, therefore you also need to configure `Tesla`, for example:

```elixir
# Configures Tesla
config :tesla, :adapter, {
  Tesla.Adapter.Finch,
  name: Aptos.Finch, receive_timeout: 15_000
}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/aptos>.

## Usage

API endpoints are implemented in `Aptos.RestClient` and `Aptos.BcsClient`. 

A faucet client is also provided in `Aptos.FaucetClient`.

When working with smart contracts, we'd like to be able to read and write data from the blockchain network.

The `Aptos.Contract.Coin` module may serve as a good example for making use of this library when working with your own smart contracts.

To submit a transaction, first generate a `{payload, payload_layout}` tuple, like in `Aptos.Contract.Coin.transfer/3`, then submit it to the network with `Aptos.Tx.submit/3`.
