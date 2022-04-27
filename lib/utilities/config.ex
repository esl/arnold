defmodule Arnold.Config do
  @moduledoc """
  Configuration handler module for Arnold.
  """

  # Train the network on every minute of the past hour
  @window_hourly 60*3

  # Train the network on every 15 minute metric of the past day (24*4)
  @window_daily 96*2

  # Train the network on every hour metric of the past week (24*4)
  @window_weekly 168*2

  # Number of seconds within an hour
  @hour 60*60

  # Number of seconds within an day
  @day 24*60*60

  # Number of seconds within an week
  @week 7*24*60*60

  # Number of seconds within an year
#  @year (365.2425)*@day

  # Default network port for REST API requests
  @port 8081

  @doc """
  Fetches a config value with a given key.
  The following default configs are configured for Arnold:

  ## Example
  ```
  iex(1)> Arnold.Config.get(:port)
  {:ok, 8081}
  iex(2)>
  ```

  The windows and ports are hard coded with the following default values:
  ```
  :hourly = 60
  :daily = 96
  :weekly = 168
  :port = 8081
  ```
  Port can be configured via a config file or setting the `ARNOLD_PORT` environment
  variable.

  ## Example
  ```
  iex(1)> Arnold.Config.get(:window, :hourly)
  {:ok, 60, 3600}
  iex(2)>
  ```
  """
  @doc since: "0.6.2"
  @spec get(key :: atom) :: {:ok, value :: [{atom, pos_integer}] | number}
  def get(:windows) do
    {:ok, [{:hourly, @window_hourly}, {:daily, @window_daily}, {:weekly, @window_weekly}]}
  end

  def get(key) do
    {:ok, Application.get_env(:arnold, key, default_value(key))}
  end

  @doc """
  Returns a value for a given `window_type`.
  The following types are accepted:
  - `:hourly`
  - `:daily`
  - `:weekly`

  ## Example
  ```
  iex(1)> Arnold.Config.get(:window, :hourly)
  {:ok, 60, 3600}
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec get(env :: atom, window_type :: atom) :: {:ok, pos_integer, pos_integer}
  def get(:window, :hourly) do
    {:ok, @window_hourly, @hour}
  end

  def get(:window, :daily) do
    {:ok, @window_daily, @day}
  end

  def get(:window, :weekly) do
    {:ok, @window_weekly, @week}
  end

  defp default_value(:port) do
    @port
  end

  defp default_value(_) do
    nil
  end

end
