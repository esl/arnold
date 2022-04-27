defmodule Arnold.Sensor.Agent do
  @moduledoc false

  @timeout 10000

  require Logger
  use Agent

  @doc """
  Entry point of the SensorAgent

  After starting the neural network application
  the agent initializes itself.
  """
  @spec start_link(opts :: term) :: {:ok, pid} |
                                    {:error, {:already_started, pid} |
                                     term}
  def start_link(opts) do
    Logger.info("Sensor Agent starting at #{inspect(self())} with id - #{opts}")
    Agent.start_link(fn -> Map.new end, name: opts)
  end

  @spec update_or_insert(agent_id :: Agent.agent, id :: binary, timestamp :: pos_integer, value :: number) :: Arnold.Database.Table.Sensor.t
  def update_or_insert(agent_id, id, timestamp, value) do
    fun =
      fn state ->
        case state[id] do
          nil ->
            insert(state, id, timestamp, value);
          sensor ->
            update(state, id, sensor, timestamp, value)
        end
      end
    Agent.get_and_update(agent_id, fun)
  end

  @spec get_state(agent_id :: Agent.agent, timeout :: pos_integer) :: map
  def get_state(agent_id, timeout \\ @timeout) do
    Agent.get(agent_id, fn state -> state end, timeout)
  end

  @spec get(agent_id :: Agent.agent, id :: binary, timeout :: pos_integer) :: Arnold.Database.Table.Sensor.t | nil
  def get(agent_id, id, timeout \\ @timeout) do
    Agent.get(agent_id, fn state -> state[id] end, timeout)
  end

  @spec reset(agent_id :: Agent.agent, id :: binary, tag :: Arnold.Sensor.tag, timeout :: pos_integer) :: :ok
  def reset(agent_id, id, tag, timeout \\ @timeout) do
    {:ok, window, _} = Arnold.Config.get(:window, tag)
    fun =
      fn state ->
        sensor = state[id]
        take = sensor.inputs[tag] |> length |> rem(window)
        values = Arnold.Utilities.truncate(sensor.inputs[tag], take)
        inputs = Map.put(sensor.inputs, tag, values)
        new_sensor = %{sensor | inputs: inputs}
        Map.put(state, id, new_sensor)
      end
    Agent.update(agent_id, fun, timeout)
  end

  @spec delete(agent_id :: Agent.agent, id :: binary, timeout :: pos_integer) :: :ok
  def delete(agent_id, sensor_id, timeout \\ @timeout) do
    Agent.update(agent_id, fn state -> Map.delete(state, sensor_id) end, timeout)
  end

  def merge(agent_id, sensor, tag, {ts, r, rh, rl}, timeout \\ @timeout) do
    fun =
      fn state ->
        [cts, cp, ch, cl] = sensor.predictions[tag]
        [first_timestamp | _] = ts
        merged =
          case Enum.find_index(cts, fn x -> x >= first_timestamp end) do
            nil ->
              [ts, r, rh, rl]
            index ->
              [do_merge(cts, ts, index), do_merge(cp, r, index), do_merge(ch, rh, index), do_merge(cl, rl, index)]
          end
        sensor_updated = %{sensor | predictions: Map.put(sensor.predictions, tag, merged)}
        {merged, Map.put(state, sensor.id ,sensor_updated)}
      end
    Agent.get_and_update(agent_id, fun, timeout)
  end

  defp insert(state, id, timestamp, value) do
    case Arnold.Database.get(Arnold.Database.Table.Sensor, id) do
      {:error, :not_found} ->
        Logger.debug("New sensor for #{id}")
        sensor = Arnold.Sensor.new(id, timestamp, value)
        {sensor, Map.put(state, id, sensor)}

      {:ok, sensor} ->
        Logger.debug("Found sensor for #{id} -> #{inspect(sensor)}")
        update(state, id, sensor, timestamp, value)
    end
  end

  defp update(state, id, sensor, timestamp, value) do
    updated_sensor = Arnold.Sensor.update(sensor, timestamp, value)
    {updated_sensor, Map.put(state, id, updated_sensor)}
  end

  defp do_merge(enum1, enum2, range), do: enum1 |> Enum.take(range) |> Enum.concat(enum2)

end
