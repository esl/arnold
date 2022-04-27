defmodule Arnold.NeuralNetwork.Models.SingleStep do
  @moduledoc false

  def linear(features) do
    Axon.input({nil, features})
    |> Axon.dense(1)
  end

  def dense(features) do
    Axon.input({nil, features})
    |> Axon.dense(64, activation: :relu)
    |> Axon.dense(64, activation: :relu)
    |> Axon.dense(1)
  end

  def example(features) do
    Axon.input({nil, features})
    |> Axon.dense(256)
    |> Axon.relu()
    |> Axon.dense(256)
    |> Axon.relu()
    |> Axon.dropout(rate: 0.3)
    |> Axon.dense(1)
    |> Axon.sigmoid()
  end
end

defmodule Arnold.NeuralNetwork.Models.MultiStep do
  @moduledoc false

  def dense(features) do
    Axon.input({nil, features})
    |> Axon.flatten
    |> Axon.dense(32, activition: :relu)
    |> Axon.dense(32, activition: :relu)
    |> Axon.dense(1)
#    |> Axon.reshape({nil,1})
  end

end

defmodule Arnold.NeuralNetwork.Models do
  @moduledoc false

  require Axon

  @max_epoch 20

  def train(model, data) do
    model
    |> Axon.Loop.trainer(:mean_squared_error, :adam)
    |> Axon.Loop.run(data, epochs: @max_epoch)
  end

  def predict(data, model, model_state) do
    Axon.predict(model, model_state, data)[0][0]
  end


  def test(model, model_state, data) do
    model
    |> Axon.Loop.evaluator(model_state)
    |> metrics()
    |> Axon.Loop.handle(:epoch_completed, &summarize/1)
    |> Axon.Loop.run(data)
  end

  defp metrics(loop) do
    loop
    |> Axon.Loop.metric(:true_positives, "tp", :running_sum)
    |> Axon.Loop.metric(:true_negatives, "tn", :running_sum)
    |> Axon.Loop.metric(:false_positives, "fp", :running_sum)
    |> Axon.Loop.metric(:false_negatives, "fn", :running_sum)
  end

  defp summarize(%Axon.Loop.State{metrics: metrics} = state) do
    IO.write("\n\n")

    false_positive = Nx.to_number(metrics["fp"])
    true_negative = Nx.to_number(metrics["tn"])
    false_negative = Nx.to_number(metrics["fn"])
    true_positive = Nx.to_number(metrics["tp"])
    total_false = false_negative + false_positive
    total_true = true_positive + true_negative

    IO.puts("Total true values: #{inspect(total_true)}")
    IO.puts("Total true values: #{inspect(total_false)}")
    {:continue, state}
  end

end
