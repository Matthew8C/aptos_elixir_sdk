defmodule Aptos.Client.Result do
  @moduledoc """
  The `Result` type holds information from API calls to an Aptos node.

  Possible results are:
  - `{:ok, headers, body}`
  - `{:error, :bad_status, http_status_code, error_info_provided_by_api_endpoint}`

  Since we are using Tesla, we may also get:
  - `{:error, tesla_error}`
  """

  alias Aptos.Client.Result.Header

  @type t :: ok() | err()
  @type ok :: {:ok, keyword(), any()}
  @type err :: {:error, :bad_status, pos_integer(), error_info()}
  @type error_info :: %{
          message: String.t(),
          error_code: String.t(),
          vm_error_code: integer()
        }
  @type from_tesla :: t() | {:error, any()}

  @spec from_tesla(Tesla.Env.result()) :: from_tesla()
  def from_tesla(res) do
    with {:ok, %Tesla.Env{} = resp} <- res do
      from_response(resp)
    end
  end

  @spec from_response(Tesla.Env.t()) :: t()
  def from_response(%Tesla.Env{status: status} = resp) when div(status, 100) == 2 do
    headers = extract_headers(resp.headers)
    succeed(headers, resp.body)
  end

  def from_response(%Tesla.Env{body: body} = resp) do
    fail(resp.status, body)
  end

  defp extract_headers(resp_headers) do
    resp_headers
    |> Enum.reduce([], fn
      {"x-aptos-" <> key, value}, acc ->
        [{key, value} | acc]

      _, acc ->
        acc
    end)
    |> Map.new(fn {key, value} ->
      {Header.underscore_key(key), Header.cast(value, key)}
    end)
  end

  @doc false
  @spec succeed(map(), any()) :: ok()
  def succeed(headers, body) do
    {:ok, headers, body}
  end

  @doc false
  @spec fail(integer(), map()) :: err()
  def fail(status_code, body) do
    {:error, :bad_status, status_code, body}
  end
end
