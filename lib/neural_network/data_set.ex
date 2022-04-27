defmodule Arnold.NeuralNetwork.DataSet do
  @moduledoc false

  defstruct [:train, :test, :features, :config]

  @type config :: Keyword.t
  @type t :: %__MODULE__{train: Enumerable.t(),
                         test: Enumerable.t(),
                         features: pos_integer,
                         config: config}

  @batch_option [leftover: :repeat]

  # @spec create(data :: map(), batch_size :: pos_integer(), shuffle :: boolean()) :: Arnold.NeuralNetwork.DataSet.t()
  @spec create(
          %{
            :features => any,
            :mean => any,
            :std => any,
            :test => number | Nx.Tensor.t(),
            :train => number | Nx.Tensor.t(),
            optional(any) => any
          },
          pos_integer,
          any
        ) :: Arnold.NeuralNetwork.DataSet.t()
  def create(data, batch_size, shuffle \\ false) do
    %{train: train_data, test: test_data, features: features, mean: mean, std: std} = data
    config = [batch_size: batch_size, shuffle: shuffle, mean: mean, std: std]
    train = to_dataset(train_data, batch_size)
    test = to_dataset(test_data, batch_size)
    %Arnold.NeuralNetwork.DataSet{train: train,
                                  test: test,
                                  features: features,
                                  config: config}
  end

  defp to_dataset(data, batch_size) do
    {n, features} = Nx.shape(data)
    features = data |> Nx.slice([1,0], [n-1, features]) |> Nx.to_batched_list(batch_size, @batch_option)
    targets = data |> Nx.slice([1,0], [n-1, 1]) |> Nx.subtract(Nx.slice(data, [0,0], [n-1, 1])) |> Nx.to_batched_list(batch_size, @batch_option)
    Stream.zip(features, targets)
  end

#  defp extend_dimension(data, batch) do
#    [head | tail] = data |> Nx.to_batched_list(batch, @batch_option)
#    Enum.reduce(tail, Nx.new_axis(head, 0, :batch), fn t,acc -> Nx.concatenate([acc,Nx.new_axis(t,0,:batch)]) end)
#  end
#
#  defp shape(data) do
#    [{input, _}] = Enum.take(data,1)
#    Nx.shape(input)
#  end

end
