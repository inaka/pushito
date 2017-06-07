defmodule Pushito.Response do
  @moduledoc """
  This module represents the APNs response
  """

  @enforce_keys [:status, :headers, :body]
  defstruct status: nil, headers: [], body: :no_body

  @type t :: %__MODULE__{status: integer, headers: list, body: :no_body | list}
end
