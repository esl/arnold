defmodule Arnold.Manager do
  @moduledoc """
  The manager responsible for saving sensors state, finished sensor tags and the number of sensor agents. If an agent
  terminates it the duty of the module to start a new one.
  """

# Interval to check if we have any new sensors to train
  @check_interval 30000

# Interval to save sensors to the database
  @save_sensors_interval 5000

# Default number of agents
  @sensor_agents 5

# Id for database
  @id "arnold_manager"

  require Logger
  use GenServer

  @doc"""
  Starts a GenServer process linked to the current process. Check `GenServer.start_link/3` for more.
  """
  def start_link(state \\ %{}, _opts \\ []) do
    Logger.info("Manager started at #{inspect(self())}")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, tref_marks} = :timer.send_interval(@check_interval, :check_marks)
    {:ok, tref_sensor} = :timer.send_interval(@save_sensors_interval, :save_sensors)

    {:ok, finished, load_balancer_data, sensor_agents, metrics} = fetch_storage_data()

    :ok = Arnold.LoadBalancer.load(load_balancer_data)
    for _i <- 1..sensor_agents, do: Arnold.LoadBalancer.start_new_sensor_agent
    {:ok,
      %{:timers => %{sensor: tref_sensor, marks: tref_marks},
        :marks => MapSet.new(),
        :finished => finished,
        :metrics => metrics}
    }
  end

  @doc"""
  Marks an `id` with a given `tag` for training.

  ## Example
  ```elixir
  iex(1)> Arnold.Manager.mark("node_sensor_id", :hourly)
  :ok
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec mark(id :: binary, tag :: Arnold.Sensor.tag) :: :ok
  def mark(id, tag) do
    GenServer.cast(__MODULE__, {:mark, {id, tag}})
  end

  @doc"""
  Checks if the `id` with the given `tag` has already finished training.

  ## Example
  ```elixir
  iex(1)> Arnold.Manager.is_finished?("node_sensor_id", :hourly)
  true
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec is_finished?(id :: binary, tag :: Arnold.Sensor.tag) :: boolean
  def is_finished?(id, tag) do
    GenServer.call(__MODULE__, {:is_finsihed, {id, tag}})
  end

  @doc"""
  Returns the state of the manager server.

  ## Example
  ```elixir
  iex(1)> Arnold.Manager.get_state
  %{:timers =>
    %{sensor: {:interval, #Reference<0.3386470258.2604662794.215684>},
      marks: {:interval, #Reference<0.3386470258.2604662794.315674>}},
    :marks => #MapSet<[]>,
    :finished => #MapSet<[]>,
    :metriccs => Map}
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec get_state() :: map
  def get_state do
    GenServer.call(__MODULE__, :state)
  end

  @doc"""
  Registers a metric to the state of the manager. Later is used for getting all the
  metrics for a given node to check the correlations.

  ## Example
  ```elixir
  iex(1)> Arnold.Manager.register("node", "sensor_id")
  :ok
  iex(2)>
  ```
  """
  @doc since: "0.6.2"
  @spec register_metric(node :: binary, sensor_id :: binary) :: :ok
  def register_metric(node, sensor_id) do
    GenServer.cast(__MODULE__, {:register, {node, sensor_id}})
  end

  @doc"""
  Returns all metrics for a given node. Used for getting all the
  metrics for a given node to check the correlations. Returns an empty MapSet
  if node not found.

  ## Example
  ```elixir
  iex(1)> Arnold.Manager.get("node")
  #MapSet<["sensor_id"]>
  iex(2)>
  ```
  """
  @doc since: "0.6.2"
  @spec get_metrics(node :: binary) :: MapSet.t()
  def get_metrics(node) do
    GenServer.call(__MODULE__, {:get, node})
  end

  @impl true
  def handle_info(:check_marks, %{marks: marks, finished: finished} = state) do
  updated =
      Enum.reduce(marks, finished, fn ({id, _tag} = object, acc) ->
        case MapSet.member?(finished, object) do
          false ->
            :ok =
              Arnold.Sensor.get(id)
              |> Arnold.NeuralNetwork.train
              |> Arnold.NeuralNetwork.save
            MapSet.put(acc, object)
          true ->
            acc
        end
      end)
    save_state(updated)
    {:noreply, %{state | finished: updated, marks: MapSet.new()}}
  end

  def handle_info(:save_sensors, state) do
    try do
      Arnold.Sensor.all |> Arnold.Database.insert
      {:noreply, state}
    catch
     :exit, e ->
       Logger.error("Could not save sensor states. Reason: #{inspect(e)}")
       {:ok, _pid} = Arnold.LoadBalancer.start_new_sensor_agent
       {:noreply, state}
    end
  end

  def handle_info(msg, state) do
    Logger.warning("Unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call({:is_finsihed, object}, _from, %{finished: finished} = state) do
    {:reply, MapSet.member?(finished, object), state}
  end

  def handle_call({:get, node}, _from, %{metrics: metrics} = state) do
    {:reply, Map.get(metrics, node, MapSet.new()), state}
  end

  def handle_call(msg, _from, state) do
    Logger.warning("Unexpected message: #{inspect(msg)}")
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:mark, object}, %{finished: finished} = state) do
    case MapSet.member?(finished, object) do
      false ->
        marks = MapSet.put(state.marks, object)
        new_state = %{state | marks: marks}
        Logger.info("Marked for train: #{inspect(new_state)}")
        {:noreply, new_state}
      true ->
        {:noreply, state}
     end
  end

  def handle_cast({:register, {node, sensor_id}}, state) do
    node_metrics = Map.get(state.metrics, node, MapSet.new())
    metrics = Map.put(state.metrics, node, MapSet.put(node_metrics, sensor_id))
    {:noreply, %{state | metrics: metrics}}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  defp fetch_storage_data do
    case Arnold.Database.get(Arnold.Database.Table.Manager, @id) do
      {:ok, data} ->
        {:ok, data.finished, data.hash_table, data.sensor_agents, %{}}
      {:error, _} ->
        {:ok, MapSet.new(), %{}, @sensor_agents, %{}}
    end
  end

  defp save_state(finished) do
    sensor_agents = Arnold.Sensor.Supervisor.children()
    load_balancer_data = Arnold.LoadBalancer.get_state
    Arnold.Database.insert(%Arnold.Database.Table.Manager{id: @id,
                                                              finished: finished,
                                                              hash_table: load_balancer_data,
                                                              sensor_agents: sensor_agents})
  end

end
