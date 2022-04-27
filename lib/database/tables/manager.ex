defmodule Arnold.Database.Table.Manager do
  @moduledoc """
  Memento table for saving the manager state.

  ## Structure
  ```
  %Arnold.Database.Table.Manager{
    id: "arnold_manager",
    finished: MapSet<[]>,
    hash_table: %{},
    sensor_agents: 40
  }
  ```

  ## Attributes
  - `id`: table id, hard coded for `"arnold_manager"`
  - `finished`: MapSet of all the finished sensor ids and tags `{sensor_id, tag}`
  - `hash_table`: Map of key-values for the Load Balancer.
  - `sensor_agents`: Number of sensor agents that should be active

  """
  @moduledoc since: "0.5.4"

  @type t :: %__MODULE__{
               id: binary,
               finished: MapSet.t,
               hash_table: map,
               sensor_agents: pos_integer
             }

  use Memento.Table,
      attributes: [:id, :finished, :hash_table, :sensor_agents],
      type: :set
end
