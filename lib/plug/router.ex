defmodule Arnold.Plug.Router do
  @moduledoc """
  Router for the REST API. There are 2 main routes, `get` and `post` paths. The body must be a json in all cases.

  `GET` paths:
    - `/api/tendency` (not used)
    - `/api/seasonality` (not used)
    - `/api/prediction`

  All of them needs 3 common parameters:
    - `node`
    - `metric`
    - `tag`

  Prediction route needs a 4th one:
    - `horizon`

  As a result a sample url path should look like this (port can be customized):
  `http://localhost:8081/api/tendency?node=node_id&metric=metric_id&tag=hourly`

  `POST` path:
    - `/api/write`

  Parameters:
    - `node`
    - `metric`

  Body:
    - `type`
    - `value`
    - `timestamp`
  Currently only gauge, counter, meter, spiral, histogram and durations are accepted via the router.
  A sample url:
  `http://localhost:8081/api/write?node=node_id&metric=metric_id` with body as json

  ```json
  {
    "type": "gauge",
    "timestamp": 1642433780,
    "value": 75
  }
  ```

  Both `GET` and `POST` methods has built-in request verification. `Arnold.Plug.InvalidGetParams` or
  `Arnold.Plug.InvalidPostParams` errors are raised if the sent request are not valid.
  """
  @moduledoc since: "0.5.4"
  use Plug.Router


  plug(Plug.Parsers, [parsers: [:json], pass: ["application/json"], json_decoder: Poison])
  plug(Arnold.Plug.VerifyGetRequest, [windows: ["hourly", "daily", "weekly"], fields: ["node", "metric", "tag", "horizon"], paths: ["/api/prediction"]])
  plug(Arnold.Plug.VerifyPostRequest, [fields: ["node", "metric"], paths: ["/api/write"]])
  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome to API of Arnold")
  end

  get "/api" do
    send_resp(conn, 200, "API of Arnold! Submenus: tendency, seasonality, prediction")
  end

#  get "/api/tendency" do
#    {node, sensor, tag} = extract_params(conn.params)
#    trend = Arnold.tendency(node, sensor, tag)
#    send_response(conn, trend, {nil, nil})
#  end

#  get "/api/seasonality" do
#    {node, sensor, tag} = extract_params(conn.params)
#    seasonality = Arnold.seasonality(node, sensor, tag)
#    send_response(conn, seasonality, {nil, nil})
#  end

  get "/api/prediction" do
    {node, sensor, tag, horizon} = extract_params(conn.params)
    {:ok, predictions} = Arnold.predict(node, sensor, tag, String.to_integer(horizon))
    alarm = Arnold.analyse(node, sensor, tag, predictions)
    send_response(conn, predictions, alarm)
  end

  post "/api/write" do
    send_to_sensor(conn.query_params, conn.body_params)
    send_resp(conn, 200, "Successfully inserted value")
  end

  match _ do
    send_resp(conn, 404, "Invalid path")
  end

  defp extract_params(params) do
    node = params["node"]
    sensor = params["metric"]
    tag = params["tag"]
    horizon = params["horizon"]
    {node, sensor, String.to_atom(tag), horizon}
  end

  defp send_to_sensor(query, body) do
    node_id = query["node"]
    sensor_id = query["metric"]
    value = get_value(body["type"], body["value"])
    time = body["timestamp"]
    Task.async(fn -> :ok = Arnold.feed(node_id, sensor_id, time, value) end)
  end

  defp get_value("spiral", value) do
    value["one"]
  end

  defp get_value("meter", value) do
    value
  end

  defp get_value(type, value) when type == "histogram" or type == "duration" do
    value["arithmetic_mean"]
  end

  defp get_value(type, value) when type == "counter" or type == "gauge" do
    value
  end

  defp send_response(conn, value, {msg, corr_msg}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{value: value, analysis: %{correlation: corr_msg, message: msg}}))
  end

end
