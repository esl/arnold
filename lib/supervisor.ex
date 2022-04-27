defmodule Arnold.Supervisor do
  @moduledoc """
  Top-level supervisor of the Arnold application.
  """
  @moduledoc since: "0.5.4"

  use Supervisor
  require Logger

  @doc """
  Starts a Supervisor process linked to the current process. Check `Supervisor.start_link/3` for more.
  """
  def start_link(init_arg) do
    Logger.debug("Supervisor starting...")
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Logger.info("Supervisor started at #{inspect(self())}")
    children = [
      %{id: :sensor_sup, start: {Arnold.Sensor.Supervisor, :start_link, []}, type: :supervisor},
      %{id: :loadbalancer_sup, start: {Arnold.LoadBalancer.Supervisor, :start_link, []}, type: :supervisor},
      %{id: :manager, start: {Arnold.Manager, :start_link, []}},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
