defmodule Arnold.Database.Table.Sensor do
  @moduledoc """
  Memento table for sensors.

  ## Structure
  ```
  %Arnold.Database.Table.Sensor{
    id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
    hourly: [],
    daily: [],
    weekly: [],
    predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}
  }
  ```

  ## Attributes
  - `id`: table id, equal to sensor id
  - `hourly`: Hourly list of inputs, with timestamps (received every minute)
  - `daily`: Daily list of inputs, with timestamps (received every 5 minute)
  - `weekly`: Weekly list of inputs, with timestamps (received every 15 minute)
  - `predictions`: Map of predictions per tag.

  """
  @moduledoc since: "0.6.0"

  @type t :: %__MODULE__{
        id: binary,
        daily: list(tuple()),
        hourly: list(tuple()),
        weekly: list(tuple()),
        predictions: map}

  use Memento.Table,
    attributes: [:id, :daily, :hourly, :weekly, :predictions],
    type: :set

end
