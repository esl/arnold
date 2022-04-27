defmodule Arnold.Plug.VerifyPostRequest do
  @moduledoc false
  require Logger

  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    if path in opts[:paths], do: verify_request!(conn.query_params, opts[:fields])
    conn
  end

  defp verify_request!(params, fields) do
    verified = contains_fields?(params, fields)
    unless verified, do: raise(Arnold.Plug.InvalidPostParams)
  end

  defp contains_fields?(params, fields) do
    params
    |> Map.keys()
    |> Enum.all?(&(&1 in fields))
  end

end
