defmodule Aptos.DataType.Parser do
  @moduledoc false

  import NimbleParsec

  hex_char = ascii_char([?0..?9, ?a..?f, ?A..?F])

  hex =
    string("0x")
    |> ignore()
    |> times(hex_char, min: 1, max: 64)
    |> reduce({List, :to_string, []})
    |> map({Aptos.Util, :hex_to_binary, []})

  valid_name =
    ascii_char([?a..?z, ?A..?Z])
    |> repeat(ascii_char([?0..?9, ?a..?z, ?A..?Z, ?_]))
    |> reduce({List, :to_string, []})

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

  type_info =
    hex
    |> tag(:account_address)
    |> concat(separator)
    |> concat(valid_name |> tag(:module_name))
    |> concat(separator)
    |> concat(valid_name |> tag(:struct_name))
    |> tag(:type_info)

  func_tag =
    hex
    |> tag(:address)
    |> concat(separator)
    |> concat(valid_name |> tag(:module))
    |> concat(separator)
    |> concat(valid_name |> tag(:name))
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

  defparsec(:type_info, type_info)
  defparsec(:func_tag, func_tag)
  defparsec(:type_tag, type_tag)
end
