defmodule Pushito.Config do
  @moduledoc """
  This module represents the connection configuration
  """

  defstruct type: :cert,
            name: nil,
            apple_host: nil,
            cert_file: nil,
            key_file: nil,
            token_key_file: nil,
            token_key_id: nil,
            team_id: nil

  @type type :: :cert | :token

  @type t :: %__MODULE__{type: type,
                         name: Pushito.connection_name | nil,
                         apple_host: String.t | nil,
                         cert_file: String.t | nil,
                         key_file: String.t | nil,
                         token_key_file: String.t | nil,
                         token_key_id: String.t | nil,
                         team_id: String.t | nil}

  @doc """
  Returns an empty config
  """
  @spec new() :: t
  def new() do
    %Pushito.Config{}
  end

  @doc """
  Adds the device_id to the notification
  """
  @spec add_type(t, type) :: t
  def add_type(config, type) do
    %{config | type: type}
  end

  @doc """
  Addss the name to the notification
  """
  @spec add_name(t, Pushito.connection_name) :: t
  def add_name(config, name) do
    %{config | name: name}
  end

  @doc """
  Adds the apple host to the notification
  """
  @spec add_host(t, String.t) :: t
  def add_host(config, host) do
    %{config | apple_host: host}
  end

  @doc """
  Adds the cert_file to the notification
  """
  @spec add_cert_file(t, String.t) :: t
  def add_cert_file(config, cert_file) do
    %{config | cert_file: cert_file}
  end

  @doc """
  Adds the key_file to the notification
  """
  @spec add_key_file(t, String.t) :: t
  def add_key_file(config, key_file) do
    %{config | key_file: key_file}
  end

  @doc """
  Adds the token_key_file to the notification
  """
  @spec add_token_key_file(t, String.t) :: t
  def add_token_key_file(config, token_key_file) do
    %{config | token_key_file: token_key_file}
  end

  @doc """
  Adds the token_key_id to the notification
  """
  @spec add_token_key_id(t, String.t) :: t
  def add_token_key_id(config, token_key_id) do
    %{config | token_key_id: token_key_id}
  end

  @doc """
  Adds the team_id to the notification
  """
  @spec add_team_id(t, String.t) :: t
  def add_team_id(config, team_id) do
    %{config | team_id: team_id}
  end
end
