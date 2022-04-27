defmodule Arnold.Plug.InvalidGetParams do
  @moduledoc """
  Error raised when a required field is missing.

  Error message:
  ```
  "Invalid params found, use these: [node, metric, tag] with tag: [hourly, daily, weekly]"
  ```
  """

  defexception message: "Invalid params found, use these: [node, metric, tag] with tag: [hourly, daily, weekly]"
end


defmodule Arnold.Plug.InvalidPostParams do
  @moduledoc """
  Error raised when a required field is missing.

  Error message:
  ```
  "Invalid params found, use these: [node, metric]"
  ```
  """

  defexception message: "Invalid params found, use these: [node, metric]"
end