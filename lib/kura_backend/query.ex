defmodule KuraBackend.Query do
  defmacro case_when(condition, do: then_expr, else: else_expr) do
    quote do
      fragment(
        "CASE WHEN ? THEN ? ELSE ? END",
        unquote(condition),
        unquote(then_expr),
        unquote(else_expr)
      )
    end
  end
end
