defmodule Arnold.Sensor do
  @moduledoc """
  Contains the API functions for the sensors
  """
  require Logger

  @limit_daily 15
  @limit_weekly 60
  @empy_predictions [[],[],[],[]]

  @typedoc """
  Time tag for sensor
  """
  @typedoc since: "0.6.2"
  @type tag :: :hourly | :daily | :weekly

  @doc """
  Creates a new Sensor with the given uuid and input value. UUID is the combination of `node_id` and `sensor_id` made with `Arnold.Utilities.id/2`.

  ## Example
  ```
  iex(1)> Arnold.Sensor.new("85a68cb6-04c7-5a78-8f4c-bcc184186b6b", 1610986020, 5)
  %Arnold.Database.Table.Sensor{
      id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
      hourly: [{1610986020, 5}],
      daily: [],
      weekly: [],
      predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}
    }
  iex(2)>
  ```
  """
  @doc since: "0.6.2"
  @spec new(uuid :: binary, timestamp :: pos_integer, value :: number) :: Arnold.Database.Table.Sensor.t()
  def new(uuid, timestamp, value) when is_number(value) do
    %Arnold.Database.Table.Sensor{
      id: uuid,
      hourly: [{timestamp, value}],
      daily: [],
      weekly: [],
      predictions: %{hourly: @empy_predictions, daily: @empy_predictions, weekly: @empy_predictions}
    }
  end

  def new(_, _, _) do
    raise ArgumentError, message: "Invalid argument while creating sensor"
  end

  @doc """
  Updates a given `sensor` with a `value`

  ## Example
  ```
  iex(1)> Arnold.Sensor.update(%Arnold.Database.Table.Sensor{
  ...(1)> id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
  ...(1)> hourly: [{1610986020, 5}],
  ...(1)> daily: [],
  ...(1)> weekly: [],
  ...(1)> predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}}, 1642593088, 7)
  %Arnold.Database.Table.Sensor{
      id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
      hourly: [{1642593088, 7},{1610986020, 5}],
      daily: [],
      weekly: [],
      predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}
    }
  iex(2)>
  ```
  """
  @doc since: "0.6.0"
  @spec update(sensor :: map, timestamp :: pos_integer, value :: number) :: map
  def update(sensor, timestamp, value) when is_number(value) do
    hourly = [{timestamp, value} | sensor.hourly]
    daily = do_update(sensor.daily, hourly, timestamp, @limit_daily)
    weekly = do_update(sensor.weekly, hourly, timestamp, @limit_weekly)
    %{sensor | hourly: hourly, daily: daily, weekly: weekly}
  end

  def update(_,_,_) do
    raise ArgumentError, message: "Invalid argument while updating sensor"
  end

  @doc """
  Puts a given `sensor` with a `value` into one of the agent's state.
  The function creates a new sensor if the agent failed to find it in its state or in the database,
  or if found one updates it.

  The agent calls the `Arnold.Sensor.new/3` and `Arnold.Sensor.update/3` functions.

  ## Example
  ```
  iex(1)> Arnold.Sensor.put("node", "sensor", 5)
  %Arnold.Database.Table.Sensor{
      id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
      hourly: [{1610986020, 5}],
      daily: [],
      weekly: [],
      predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}
    }
  iex(2)>
  ```
  """
  @doc since: "0.6.0"
  @spec put(node_id :: binary, sensor_id :: binary, time :: pos_integer, value :: number) :: Arnold.Database.Table.Sensor.t
  def put(node_id, sensor_id, timestamp, value) do
    id = Arnold.Utilities.id(node_id, sensor_id)
    Logger.debug("Put #{node_id} - #{sensor_id} -#{inspect(value)}")
    Arnold.LoadBalancer.get_agent_id(id) |> Arnold.Sensor.Agent.update_or_insert(id, timestamp, value)
  end

  @doc """
  Returns all sensors from every sensor agent.

  ## Example
  ```
  iex(1)> Arnold.Sensor.all
  [%Arnold.Database.Table.Sensor{
      id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
      hourly: [{1610986020, 5}],
      daily: [],
      weekly: [],
      predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}
  },
  %Arnold.Database.Table.Sensor{
      id: "adff7462-a100-55be-8ee1-8f8c34d3a9e3",
      hourly: [{1610986020, 6}],
      daily: [],
      weekly: [],
      predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}
  }]
  iex(2)>
  ```
  """
  @doc since: "0.6.0"
  @spec all :: [Arnold.Database.Table.Sensor.t]
  def all do
    for x <- 0..Arnold.Sensor.Supervisor.children()-1, x >= 0 do
      Arnold.LoadBalancer.to_agent_id(x)
      |> Arnold.Sensor.Agent.get_state
      |> Map.values
    end
    |> List.flatten
  end

  @doc """
  Returns a sensor from with the given `uuid`. Only returns the sensor if it is in the state of
  the agent. UUID is the combination of `node_id` and `sensor_id` made with `Arnold.Utilities.id/2`.

  ## Example
  ```
  iex(1)> Arnold.Sensor.get("85a68cb6-04c7-5a78-8f4c-bcc184186b6b")
  %Arnold.Database.Table.Sensor{
      id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
      hourly: [{1610986020, 5}],
      daily: [],
      weekly: [],
      predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}
  }
  iex(2)>
  ```
  """
  @doc since: "0.6.0"
  @spec get(id :: binary) :: Arnold.Database.Table.Sensor.t | nil
  def get(uuid) do
    Arnold.LoadBalancer.get_agent_id(uuid) |> Arnold.Sensor.Agent.get(uuid)
  end

  @doc """
  Deletes a sensor from a given `uuid`. UUID is the combination of `node_id` and `sensor_id` made with `Arnold.Utilities.id/2`.

  ## Example
  ```
  iex(1)> Arnold.Sensor.delete("85a68cb6-04c7-5a78-8f4c-bcc184186b6b")
  :ok
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec delete(uuid :: binary) :: :ok
  def delete(uuid) do
    Arnold.LoadBalancer.get_agent_id(uuid) |> Arnold.Sensor.Agent.delete(uuid)
  end

  @doc """
  Resets a sensor with a given `uuid` and `tag`. It means that truncates the input values for the given `tag`.
  UUID is the combination of `node_id` and `sensor_id` made with `Arnold.Utilities.id/2`.

  ## Example
  ```
  iex(1)> Arnold.Sensor.reset("85a68cb6-04c7-5a78-8f4c-bcc184186b6b", :hourly)
  :ok
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec reset(uuid :: binary, tag :: Arnold.Sensor.tag) :: :ok
  def reset(uuid, tag), do: Arnold.LoadBalancer.get_agent_id(uuid) |> Arnold.Sensor.Agent.reset(uuid, tag)


  @doc """
  Gets the values from the input proplist.

  ## Example
  ```
  iex(1)> Arnold.Sensor.values([{1610986020, 46386}, {1610989620, 3456}])
  [46386, 3456]
  iex(2)>
  ```
  """
  @spec values(input :: [tuple]) :: [number]
  def values(input), do: for {_timestamp, value} <- input, do: value

  def merge(sensor, tag, values), do: Arnold.LoadBalancer.get_agent_id(sensor.id) |> Arnold.Sensor.Agent.merge(sensor, tag, values)

  defp do_update(list_to_update, updated_by, timestamp, limit) do
    len = updated_by |> length
    case rem(len, limit) do
      0  when updated_by != [] ->
        div = fn x,y -> x / y |> round end
        avg = Enum.take(updated_by, limit) |> Enum.reduce(0,fn {_ts, value}, acc -> value + acc end) |> div.(limit)
        [{timestamp, avg} | list_to_update]
      _ ->
        list_to_update
    end
  end

end
