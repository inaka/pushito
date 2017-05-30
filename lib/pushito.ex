defmodule Pushito do
  use Application
  @moduledoc """
  This is the main module for Pushito. Here there are the functions to connect and push to APNs.
  """

  @doc """
  Application callback for starting Pushito.
  """
  def start(_type, _args) do
    Pushito.Supervisor.start_link
  end
end
