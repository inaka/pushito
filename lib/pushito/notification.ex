defmodule Pushito.Notification do
  @moduledoc """
  This module represents the notification to be pushed. It contains all the information needed.
  """

  @enforce_keys [:device_id, :apns_topic]
  defstruct device_id: nil,
            apns_expiration: 0,
            apns_priority: 10,
            apns_topic: nil,
            apns_id: nil,
            apns_collapse_id: nil,
            token: nil,
            timeout: 10,
            message: %{}

  @type t :: %__MODULE__{device_id: String.t,
                         apns_expiration: integer,
                         apns_priority: 10 | 5,
                         apns_topic: String.t,
                         apns_id: String.t,
                         apns_collapse_id: String.t,
                         token: String.t,
                         timeout: integer,
                         message: map}
end
