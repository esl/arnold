defmodule Arnold.LoadBalancer.Supervisor do
  @moduledoc false
  require Logger
  use Supervisor

  def start_link(arg \\ []) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    Logger.info("Load Balancer Supervisor started at #{inspect(self())}")
    children = [%{id: :load_balancer, start: {Arnold.LoadBalancer.Agent, :start_link, []}}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
