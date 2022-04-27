defmodule Arnold.Sensor.Supervisor do
  @moduledoc """
  Dynamic supervisor which can start Sensor Agents when needed.
  """

  require Logger
  use DynamicSupervisor

  @doc"""
  Starts a supervisor with the given children.

  ## Example
  ```
  iex(1)> Arnold.Supervisor.start_link()
  {:ok, #PID<0.3834.0>}
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec start_link(list) :: Supervisor.on_start()
  def start_link(init_arg \\ []) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end


  @doc"""
  Starts a child with the given `id`.

  ## Example
  ```
  iex(1)> Arnold.Supervisor.start_child(:sensor1)
  {:ok, #PID<0.345.0>}
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec start_child(id :: atom) :: DynamicSupervisor.on_start_child()
  def start_child(id) do
    spec = %{id: id, start: {Arnold.Sensor.Agent, :start_link, [id]}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_init_arg) do
    Logger.info("Sensor Dynamic Supervisor started at #{inspect(self())}")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc"""
  Restarts a child with the given `id`.

  ## Example
  ```
  iex(1)> Arnold.Supervisor.restart_child(:sensor1)
  {:ok, #PID<0.345.0>}
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec restart_child(child_id :: atom) :: DynamicSupervisor.on_start_child() | {:error, :missing_child}
  def restart_child(child_id) do
    case Process.whereis(child_id) do
      nil ->
        {:error, :missing_child}
      pid ->
        DynamicSupervisor.terminate_child(Arnold.Sensor.Supervisor, pid)
        start_child(child_id)
    end
  end

  @doc"""
  Returns the number of workers for the supervisor.

  ## Example
  ```
  iex(1)> Arnold.Supervisor.children
  2
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec children :: non_neg_integer
  def children do
    DynamicSupervisor.count_children(__MODULE__).workers
  end

  @doc"""
  Returns the number of active children for the supervisor.
  *May differ from the number of children*

  ## Example
  ```
  iex(1)> Arnold.Supervisor.active_children
  1
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec active_children :: non_neg_integer
  def active_children do
    DynamicSupervisor.count_children(__MODULE__).active
  end

end
