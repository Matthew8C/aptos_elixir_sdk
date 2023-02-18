defmodule Aptos.Tx.FuncTag.Parser do
  @moduledoc false

  import NimbleParsec

  hex_char = ascii_char([?0..?9, ?a..?d, ?A..?D])

  hex =
    string("0x")
    |> ignore()
    |> times(hex_char, min: 1, max: 64)
    |> reduce({List, :to_string, []})
    |> map({Aptos.Util, :hex_to_binary, []})
    |> tag(:address)

  module =
    ascii_char([?a..?z, ?A..?z])
    |> repeat(ascii_char([?0..?9, ?a..?z, ?A..?z, ?_]))
    |> tag(:module)

  name =
    ascii_char([?a..?z, ?A..?z])
    |> repeat(ascii_char([?0..?9, ?a..?z, ?A..?z, ?_]))
    |> tag(:name)

  separator = ignore(string("::"))

  type_arguments =
    string("<")
    |> ignore()
    |> repeat_while(
      parsec(:type_tag) |> optional(ignore(string(", "))),
      {:not_closing_bracket, []}
    )
    |> concat(ignore(string(">")))
    |> tag(:type_arguments)

  defp not_closing_bracket(">" <> _, context, _, _) do
    {:halt, context}
  end

  defp not_closing_bracket(_, context, _, _) do
    {:cont, context}
  end

  vector =
    string("vector")
    |> ignore()
    |> concat(type_arguments)
    |> tag(:vector)

  func_tag =
    hex
    |> concat(separator)
    |> concat(module)
    |> concat(separator)
    |> concat(name)
    |> concat(optional(type_arguments))
    |> tag(:func_tag)

  type_tag =
    choice([
      string("bool"),
      string("u8"),
      string("u16"),
      string("u32"),
      string("u64"),
      string("u128"),
      string("u256"),
      string("address"),
      vector,
      func_tag
    ])

  defparsec(:func_tag, func_tag)
  defparsec(:type_tag, type_tag)
end
