defmodule Arnold.Plug.VerifyGetRequest do
  @moduledoc false
  require Logger

  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    if path in opts[:paths], do: verify_request!(conn.params, opts[:fields], opts[:windows])
    conn
  end

  defp verify_request!(params, fields, windows) do
    verified = contains_fields?(params, fields) && is_valid_tag?(params["tag"], windows)

    unless verified, do: raise(Arnold.Plug.InvalidGetParams)
  end

  defp contains_fields?(params, fields) do
    params
    |> Map.keys()
    |> Enum.all?(&(&1 in fields))
  end

  defp is_valid_tag?(tag, windows) do
    Enum.member?(windows, tag)
  end
end
