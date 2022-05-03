defmodule Arnold.Utilities do
  @moduledoc """
  Collection of utility functions including id generation, truncate and normalization functions.
  """


  @doc """
  Truncates a given list to the given length

  ## Example
  ```
  iex(1)> Arnold.Utilities.truncate([1,2,3,4,5], 4)
  [1, 2, 3, 4]
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec truncate(list(), pos_integer()) :: list()
  def truncate(inputs, threshold) do
    Enum.take(inputs, threshold)
  end

  @doc """
  Normalizes a list of floats or integers with min-max normalization.
  Automatically gets the minimum and maximum values from the given list.
  Calls to `Arnold.Utilities.normalize/3`

  ## Example
  ```
  iex(1)> Arnold.Utilities.normalize([1,2,3,4,5])
  {[0.0, 0.25, 0.5, 0.75, 1.0], 1, 5}
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec normalize(inputs :: [number]) :: {[number], integer, integer}
  def normalize(inputs) do
    {min, max} = Enum.min_max(inputs)
    normalize(inputs, min, max)
  end


  @doc """
  Normalizes a list of floats or integers, or single values with min-max normalization.
  For every element `Arnold.Utilities.normalize/3` is called.

  ## Example
  ```
  iex(1)> Arnold.Utilities.normalize(4,1,5)
  0.75
  iex(2)> Arnold.Utilities.normalize([4,3,4,1], 1,5)
  {[0.75, 0.5, 0.75, 0.0], 1, 5}
  ```
  """
  @doc since: "0.5.4"
  @spec normalize(x :: number | list, min :: number, max :: number) :: {number | [number], integer, integer}
  def normalize(inputs, min, max) when is_list(inputs) do
    {Enum.map(inputs, fn x -> normalize(x, min, max) end), min, max}
  end

  def normalize(_x, y, y) do
    0
  end

  def normalize(x, min, max) do
    (x-min)/(max-min)
  end

  @doc """
  Returns the result of the normalize function return value.
  Mainly used in pipe operations

  ## Example
  ```
  iex(1)> Arnold.Utilities.normalize([4,3,4,1],1,5)
  ...(1)> |> Arnold.Utilities.normal_result
  [0.75, 0.5, 0.75, 0.0]
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec normal_result({x :: number | list, min :: number, max :: number}) :: number | [number]
  def normal_result({res, _, _} = _result_of_normalize_function), do: res

  @doc """
  Denormalizes a value with the given `min` and `max` value.

  Example:
  iex(1)> Arnold.Utilities.denormalize(0.75,1,5)
  4.0
  iex(2)>
  """
  @doc since: "0.5.4"
  @spec denormalize(x :: number, min :: number, max :: number) :: float
  def denormalize(x, min, max) do
    (x * (max - min)) + min
  end

  @doc """
  Return a generated UUID v5 based on the given ids.

  ## Example
  ```
  iex(1)> Arnold.Utilities.id("node", "sensor")
  "85a68cb6-04c7-5a78-8f4c-bcc184186b6b"
  iex(2)>
  ```
  """
  @doc since: "0.6.2"
  @spec id(id1 :: binary, id2 :: binary) :: binary
  def id(id1, id2) when is_binary(id1) and is_binary(id2) do
    UUID.uuid5(:dns, id1 <> id2)
  end

  def id(_, _) do
    raise ArgumentError, message: "Invalid argument. Check if both parameters are binaries or strings"
  end

  @doc """
  Checks if the given list is only has constant values.

  ## Example
  ```
  iex(1)> Arnold.Utilities.is_constant?([1,2,3,4,5,6])
  false
  iex(2)>
  ```
  """
  @doc since: "0.5.4"
  @spec is_constant?(x :: list) :: boolean
  def is_constant?([]) do
    true
  end

  def is_constant?([h | _ ] = list) do
    Enum.all?(list, fn x -> x == h end)
  end

  @doc """
  Converts an integer to bool.
  1 = true, otherwise false.

  ## Example
  ```
  iex(1)> Arnold.Utilities.integer_to_boolean(1)
  true
  iex(2)> Arnold.Utilities.integer_to_boolean(2)
  false
  ```
  """
  @spec integer_to_boolean(number :: integer) :: boolean
  def integer_to_boolean(number) do
    number == 1
  end

end
