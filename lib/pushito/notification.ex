defmodule Pushito.Notification do
  @moduledoc """
  This module represents the notification to be pushed. It contains all the information needed.
  """

  defstruct device_id: nil,
            apns_expiration: 0,
            apns_priority: 10,
            apns_topic: nil,
            apns_id: nil,
            apns_collapse_id: nil,
            token: nil,
            timeout: 10,
            message: %{}

  @type t :: %__MODULE__{device_id: String.t | nil,
                         apns_expiration: integer,
                         apns_priority: 5 | 10,
                         apns_topic: String.t | nil,
                         apns_id: String.t | nil,
                         apns_collapse_id: String.t | nil,
                         token: String.t | nil,
                         timeout: integer,
                         message: map}

  @doc """
  Returns an empty notification
  """
  @spec new() :: t
  def new() do
    %Pushito.Notification{}
  end

  @doc """
  Adds the device_id to the notification
  """
  @spec add_device_id(t, String.t) :: t
  def add_device_id(notification, device_id) do
    %{notification | device_id: device_id}
  end

  @doc """
  Adds the apns_expiration to the notification
  """
  @spec add_expiration(t, integer) :: t
  def add_expiration(notification, expiration) do
    %{notification | apns_expiration: expiration}
  end

  @doc """
  Adds the apns_priority to the notification
  """
  @spec add_priority(t, integer) :: t
  def add_priority(notification, priority) do
    %{notification | apns_priority: priority}
  end

  @doc """
  Adds the apns_topic to the notification
  """
  @spec add_topic(t, integer) :: t
  def add_topic(notification, topic) do
    %{notification | apns_topic: topic}
  end

  @doc """
  Adds the apns_id to the notification
  """
  @spec add_id(t, integer) :: t
  def add_id(notification, id) do
    %{notification | apns_id: id}
  end

  @doc """
  Adds the apns_collapse_id to the notification
  """
  @spec add_collapse_id(t, integer) :: t
  def add_collapse_id(notification, collapse_id) do
    %{notification | apns_collapse_id: collapse_id}
  end

  @doc """
  Adds the token to the notification
  """
  @spec add_token(t, String.t) :: t
  def add_token(notification, token) do
    %{notification | token: token}
  end

  @doc """
  Adds the timeout to the notification
  """
  @spec add_timeout(t, integer) :: t
  def add_timeout(notification, timeout) do
    %{notification | timeout: timeout}
  end

  @doc """
  Adds the message to the notification
  """
  @spec add_message(t, map) :: t
  def add_message(notification, message) do
    %{notification | message: message}
  end
end
