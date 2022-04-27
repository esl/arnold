defmodule Arnold.LoadBalancer.Agent do
  @moduledoc false
  require Logger

  @spec start_link(opts :: term) :: {:ok, pid} |
                                    {:error, {:already_started, pid} |
                                             term}
  def start_link(_opts \\ []) do
    Logger.info("Load Balancer Agent starting at #{inspect(self())}")
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Insert a hash value with the specific sensor_id into the state the LoadBalancer agent
  """
  def insert(sensor_id) do
    fun =
      fn state ->
        case state[sensor_id] do
          nil ->
            agent_id = hash(sensor_id)
            {agent_id, Map.put(state, sensor_id, agent_id)};
          hash ->
            {hash, state}
        end
      end
    Agent.get_and_update(__MODULE__, fun)
  end

  @doc """
  Returns the state of the Load Balancer agent
  """
  @spec get :: map
  def get do
    Agent.get(__MODULE__, fn state -> state end)
  end

  @doc """
  Returns the hash number for a specific sensor_id if it exists,
  else returns `nil`
  """
  @spec get(sensor_id :: binary) :: non_neg_integer | nil
  def get(sensor_id) do
    Agent.get(__MODULE__, fn state -> state[sensor_id] end)
  end

  @doc """
  If a new sensor agent is added, maybe there is a need to rebalance the metrics
  """
  def maybe_replace(sensor_id, hash) do
    fun =
      fn state ->
        case hash(sensor_id) do
          ^hash ->
            {hash, state}
          new_hash ->
            Arnold.LoadBalancer.to_agent_id(hash) |> Arnold.Sensor.Agent.delete(sensor_id)
            {new_hash, Map.replace!(state, sensor_id, new_hash)};
        end
      end
    Agent.get_and_update(__MODULE__, fun)
  end

  @doc """
  Clears the state of the Load Balancer agent asynchronously
  """
  def clear do
    Agent.cast(__MODULE__, fn _state -> %{} end)
  end

  def load(data) do
    Agent.update(__MODULE__, fn _ -> data end)
  end

  defp hash(sensor_id) do
    Arnold.Sensor.Supervisor.children() |> hash(sensor_id)
  end

  defp hash(range, sensor_id) do
    :erlang.phash2(sensor_id, range)
  end

end
