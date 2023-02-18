defmodule Aptos.Tx.Payload do
  defmodule Script do
    @moduledoc false

    defstruct [:code, :type_arguments, :arguments]

    @type t() :: %__MODULE__{
            code: map(),
            type_arguments: list(String.t()),
            arguments: list()
          }

    def new(attrs \\ []) do
      struct(__MODULE__, attrs)
    end
  end

  defmodule ModuleBundle do
    @moduledoc false

    defstruct [:modules]

    @type t() :: %__MODULE__{modules: list(map())}

    def new(attrs \\ []) do
      struct(__MODULE__, attrs)
    end
  end

  defmodule EntryFunction do
    alias BCS.DataType, as: T
    alias Aptos.Tx.FuncTag

    defstruct [:func_tag, :arguments]

    @type t() :: %__MODULE__{
            func_tag: FuncTag.t(),
            arguments: list()
          }

    @spec bcs_layout(list(T.t()), list(T.t())) :: keyword(T.t())
    def bcs_layout(t_args_layout, arg_layout) do
      [
        func_tag: FuncTag.t(t_args_layout),
        arguments: T.DoubleEncode.t(arg_layout)
      ]
    end

    def new(attrs \\ []) do
      struct(__MODULE__, attrs)
    end
  end

  @type t :: Script.t() | ModuleBundle.t() | EntryFunction.t()

  alias BCS.DataType, as: T

  @spec bcs_layout(:entry_function, list(T.t()), list(T.t())) :: T.Choice.t()
  def bcs_layout(:entry_function, t_args_layout, arg_layout) do
    EntryFunction.bcs_layout(t_args_layout, arg_layout)
    |> T.Struct.t()
    |> T.Choice.t(2)
  end
end
