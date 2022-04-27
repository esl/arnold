defmodule Arnold.Application do
  @moduledoc false
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Application started at: #{inspect(self())}")
    setup_mnesia()
    port =
      case System.get_env("ARNOLD_PORT") do
        nil ->
          {:ok, p} = Arnold.Config.get(:port)
          p
        env -> String.to_integer(env)
      end
    children = [{Arnold.Supervisor,[]}, {Plug.Cowboy, scheme: :http, plug: Arnold.Plug.Router, options: [port: port]}]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @impl true
  def stop(_state) do
    :ok
  end

  defp setup_mnesia do

    if path = Application.get_env(:mnesia, :dir) do
      :ok = File.mkdir_p!(path)
    end

    # Setup persistent storage for a specific node
    nodes = [node()]
    Memento.stop()
    Memento.Schema.create(nodes)
    Memento.start()


    Memento.Table.create(Arnold.Database.Table.Sensor, disc_copies: nodes)
    Memento.Table.create(Arnold.Database.Table.NetworkModel, disc_copies: nodes)
    Memento.Table.create(Arnold.Database.Table.Manager, disc_copies: nodes)

  end

end
