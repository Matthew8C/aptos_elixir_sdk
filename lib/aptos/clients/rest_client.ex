defmodule Aptos.RestClient do
  @moduledoc """
  JSON endpoints to read data from the network
  """

  @endpoint Aptos.NetworkConfig.node_url()

  use Tesla, docs: false

  plug Tesla.Middleware.BaseUrl, @endpoint
  plug Tesla.Middleware.JSON, engine_opts: [keys: :atoms]
  plug Tesla.Middleware.Timeout, timeout: 15_000

  alias Aptos.Client.Result

  import Aptos.Util

  # Account

  @doc """
  Fetches the authentication key and the sequence number for an account address.

  Available options are:
  - `{:ledger_version, pos_integer()}`
  """
  @spec show_account(binary, keyword()) :: Result.from_tesla()
  def show_account(address, opts \\ []) do
    address = "0x" <> Base.encode16(address, case: :lower)

    get("/accounts/#{address}", query: opts)
    |> Result.from_tesla()
  end

  @doc """
  Retrieves a collection of account resources for a given account.

  Available options are:
  - `{:ledger_version, pos_integer()}`
  - `{:limit, pos_integer()}`
  - `{:start, String.t()}`
  """
  @spec list_account_resources(binary, keyword()) :: Result.from_tesla()
  def list_account_resources(address, opts \\ []) do
    get("/accounts/#{binary_to_hex(address)}/resources", query: opts)
    |> Result.from_tesla()
  end

  @doc """
  Retrieves all account resources for a given account, automatically running through pagination.

  Available options are:
  - `{:ledger_version, pos_integer()}`
  """
  @spec list_all_account_resources(binary, keyword()) :: Result.from_tesla()
  def list_all_account_resources(address, opts \\ []) do
    fetch_all_by_cursor(:list_account_resources, [address], opts)
  end

  @doc """
  Retrieves an individual resource from a given account.

  Available options are:
  - `{:ledger_version, pos_integer()}`
  """
  @spec show_account_resource(binary, String.t(), keyword()) :: Result.from_tesla()
  def show_account_resource(address, resource, opts \\ []) do
    get("/accounts/#{binary_to_hex(address)}/resource/#{URI.encode(resource)}", query: opts)
    |> Result.from_tesla()
  end

  @doc """
  Retrieves a collection of account modules' bytecode for a given account.

  Available options are:
  - `{:ledger_version, pos_integer()}`
  - `{:limit, pos_integer()}`
  - `{:start, String.t()}`
  """
  @spec list_account_modules(binary, keyword()) :: Result.from_tesla()
  def list_account_modules(address, opts \\ []) do
    get("/accounts/#{binary_to_hex(address)}/modules", query: opts)
    |> Result.from_tesla()
  end

  @doc """
  Retrieves all account modules' bytecode for a given account, automatically running through pagination.

  Available options are:
  - `{:ledger_version, pos_integer()}`
  """
  @spec list_all_account_modules(binary, keyword()) :: Result.from_tesla()
  def list_all_account_modules(address, opts \\ []) do
    fetch_all_by_cursor(:list_account_modules, [address], opts)
  end

  @doc """
  Retrieves an individual module from a given account.

  Available options are:
  - `{:ledger_version, pos_integer()}`
  """
  @spec show_account_module(binary, String.t(), keyword()) :: Result.from_tesla()
  def show_account_module(address, module_name, opts \\ []) do
    get("/accounts/#{binary_to_hex(address)}/module/#{module_name}", query: [])
    |> Result.from_tesla()
  end

  # Blocks

  @doc """
  Fetches a block by its height.
  """
  @spec show_block_by_height(non_neg_integer(), keyword()) :: Result.from_tesla()
  def show_block_by_height(height, opts \\ []) do
    get("/blocks/by_height/#{height}", query: opts)
    |> Result.from_tesla()
  end

  @doc """
  Fetches a block by a version in the block.
  """
  @spec show_block_by_version(non_neg_integer(), keyword()) :: Result.from_tesla()
  def show_block_by_version(version, opts \\ []) do
    get("/blocks/by_version/#{version}", query: opts)
    |> Result.from_tesla()
  end

  # Transactions

  @doc """
  Looks up a transaction by its hash.
  """
  @spec show_tx_by_hash(String.t()) :: Result.from_tesla()
  def show_tx_by_hash(tx_hash) do
    get("/transactions/by_hash/#{tx_hash}")
    |> Result.from_tesla()
  end

  @doc """
  Retrieves a transaction by a given version.
  """
  @spec show_tx_by_version(pos_integer()) :: Result.from_tesla()
  def show_tx_by_version(version_number) do
    get("/transactions/by_version/#{version_number}")
    |> Result.from_tesla()
  end

  @doc """
  Retrieves on-chain committed transactions.

  Available options are:
  - `{:limit, pos_integer()}`
  - `{:start, pos_integer()}`
  """
  @spec list_tx(keyword()) :: Result.from_tesla()
  def list_tx(opts \\ []) do
    get("transactions", query: opts)
    |> Result.from_tesla()
  end

  @doc """
  Retrieves on-chain committed transactions from an account.

  Available options are:
  - `{:limit, pos_integer()}`
  - `{:start, pos_integer()}`
  """
  @spec list_account_tx(binary, keyword()) :: Result.from_tesla()
  def list_account_tx(address, opts \\ []) do
    get("/accounts/#{binary_to_hex(address)}/transactions", query: opts)
    |> Result.from_tesla()
  end

  @doc """
  Retrieves estimated gas price from node.
  """
  @spec estimate_gas_price() :: Result.from_tesla()
  def estimate_gas_price() do
    get("/estimate_gas_price")
    |> Result.from_tesla()
  end

  # Tables

  @doc """
  Retrieves a table item.

  Available options are:
  - `{:ledger_version, pos_integer()}`
  """
  @spec show_table_item(String.t(), String.t(), String.t(), String.t()) :: Result.from_tesla()
  def show_table_item(key, handle, key_type, value_type, opts \\ []) do
    body = %{
      key_type: key_type,
      value_type: value_type,
      key: key
    }

    post("/tables/#{handle}/item", body, query: opts)
    |> Result.from_tesla()
  end

  # Events

  @doc """
  Fetches events by event handle.

  Available options are:
  - `{:limit, pos_integer()}`
  - `{:start, pos_integer()}`
  """
  @spec list_events_by_handle(binary(), String.t(), String.t(), keyword()) :: Result.from_tesla()
  def list_events_by_handle(address, handle, field, opts \\ []) do
    get("/accounts/#{binary_to_hex(address)}/events/#{handle}/#{field}", query: opts)
    |> Result.from_tesla()
  end

  @doc """
  Fetches events by creation number.

  Available options are:
  - `{:limit, pos_integer()}`
  - `{:start, pos_integer()}`
  """
  @spec list_events_by_creation_number(binary(), pos_integer(), keyword()) :: Result.from_tesla()
  def list_events_by_creation_number(address, creation_number, opts \\ []) do
    get("/accounts/#{binary_to_hex(address)}/events/#{creation_number}", query: opts)
    |> Result.from_tesla()
  end

  # Helpers

  defp fetch_all_by_cursor(func, args, opts) do
    cleaned_opts = Keyword.drop(opts, [:cursor, :limit])
    fetch_all_by_cursor(func, args, cleaned_opts, nil, [])
  end

  defp fetch_all_by_cursor(func, args, opts, cursor, fetched) do
    merged_opts =
      if cursor do
        Keyword.put(opts, :start, cursor)
      else
        opts
      end

    with {:ok, headers, entries} <-
           apply(__MODULE__, func, args ++ [merged_opts]) do
      case headers[:cursor] do
        nil ->
          {:ok, headers, fetched ++ entries}

        new_cursor ->
          fetch_all_by_cursor(func, args, opts, new_cursor, fetched ++ entries)
      end
    end
  end
end
