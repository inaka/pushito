defmodule Pushito.Config do
  @moduledoc """
  This module represents the connection configuration
  """

  @enforce_keys [:name, :apple_host]
  defstruct type: :cert,
            name: nil,
            apple_host: nil,
            cert_file: nil,
            key_file: nil,
            timeout: 10

  @type type :: :cert | :token

  @type t :: %__MODULE__{type: type,
                         name: atom,
                         apple_host: String.t,
                         cert_file: String.t,
                         key_file: String.t,
                         timeout: integer}
end
