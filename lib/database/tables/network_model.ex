defmodule Arnold.Database.Table.NetworkModel do
  @moduledoc """
  Memento table for neural network weights.

  ## Structure
  ```
  %Arnold.Database.Table.NetworkModel{
    id: "85a68cb6-04c7-5a78-8f4c-bcc184186b6b",
    dataset: %{},
    model: %{},
    model_state: %{},
  }
  ```

  ## Attributes
  - `id`: table id, equal to sensor id
  - `dataset`: dataset
  - `model`: table id, equal to sensor id
  - `model_state`: table id, equal to sensor id

  """
  @moduledoc since: "0.6.0"

  @type t :: %__MODULE__{
         id: binary,
         dataset: map,
         model: map,
         model_state: map}

  use Memento.Table,
      attributes: [:id, :dataset, :model, :model_state],
      type: :set

end
