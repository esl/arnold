defmodule Arnold.LoadBalancer do
  @moduledoc false

  @spec get_hash(id :: binary) :: non_neg_integer
  def get_hash(id) do
    case Arnold.LoadBalancer.Agent.get(id) do
      nil ->
        Arnold.LoadBalancer.Agent.insert(id);
      hash ->
        Arnold.LoadBalancer.Agent.maybe_replace(id, hash);
    end
  end

  @spec get_agent_id(id :: binary) :: atom
  def get_agent_id(id) when is_binary(id) do
    get_hash(id) |> to_agent_id()
  end

  @spec to_agent_id(hash :: non_neg_integer) :: atom
  def to_agent_id(hash) do
    value = hash |> Integer.to_string
    "sensor" <> value |> String.to_atom
  end

  @doc"""
  Restarts current active Sensor agents, which clears their states, then starts a new one
  """
  @spec start_new_sensor_agent :: DynamicSupervisor.on_start_child
  def start_new_sensor_agent do
    Arnold.Sensor.Supervisor.children |> to_agent_id |> Arnold.Sensor.Supervisor.start_child
  end

  @spec load(data :: map) :: :ok
  def load(data) when data == %{} do
    :ok
  end

  def load(data) do
    Arnold.LoadBalancer.Agent.load(data)
  end

  def get_state do
    Arnold.LoadBalancer.Agent.get
  end

end
