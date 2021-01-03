defmodule Brave do
  @moduledoc """
  Brave keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def find_missing_params(params, fields) do
    errors = Enum.reduce(fields, %{}, fn(field, acc) ->
      if(params[field] == nil) do
        Map.put(acc, field, ["required field"])
      else
        acc
      end
    end)
    %{errors: errors}
  end
end
