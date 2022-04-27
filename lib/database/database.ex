defmodule Arnold.Database do
  @moduledoc """
  API wrapper for Memento to store or fetch data from the database.
  """
  @moduledoc since: "0.5.4"

  require Logger

  @doc"""
  Fetches data from database. Needs a `table schema` and an `uuid` which is made from the combination
  of `node_name` and `sensor_id` with `Arnold.Utilities.id/2`.

  ## Example
  ```
  iex(1)> Arnold.Database(Arnold.Database.Table.Sensor, "85a68cb6-04c7-5a78-8f4c-bcc184186b6b")
  {:ok, %Arnold.Database.Table.Sensor{
    id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
    hourly: [{1610986020, 5}],
    daily: [],
    weekly: [],
    predictions: %{hourly: [[],[],[],[]], daily: [[],[],[],[]], weekly: [[],[],[],[]]}
  }}
  iex(2)>
  ```
  """
  @spec get(schema :: module, uuid :: binary) :: {:ok, term} | {:error, :not_found}
  def get(table, uuid) do
    Logger.debug("Reading from #{inspect(table)} with #{uuid}")
    case Memento.transaction!(fn -> Memento.Query.read(table, uuid) end) do
      nil ->
        {:error, :not_found}
      data ->
        {:ok, data}
    end
  end

  @doc """
  Tries to fetch a specific node_id and sensor_id from a table. If not found returns all the currently saved data from the backend
  """
  @spec get(schema :: module, node_id :: binary, sensor_id :: binary) :: {:ok, term} | {:error, :not_found}
  def get(schema, node_id, sensor_id) do
    get(schema, Arnold.Utilities.id(node_id, sensor_id))
  end

  @doc """
  Inserts the data to the specific table of the Postgres database. If it's there
  updates the value
  """
  @spec insert(data :: list | map) :: :ok
  def insert([]) do
    :ok
  end

  def insert(data) when is_list(data) do
    for x <- data, do: :ok = insert(x)
  end

  def insert(data) do
    Logger.debug("Inserting into with #{data.id}")
    ^data = Memento.transaction!(fn -> Memento.Query.write(data) end)
    :ok
  end
end
