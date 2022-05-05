defmodule Arnold.Statistics.MannKendall do
  @moduledoc false
  @moduledoc since: "0.5.4"

  @alpha 0.05

  @spec execute(Nx.Tensor.t) ::
          {pos_integer, float, Nx.Tensor.t, Nx.Tensor.t, Nx.Tensor.t, Nx.Tensor.t, Nx.Tensor.t, boolean}
  def execute(input) do
    n = Nx.size(input)
    f = input |> ties_correction(n-1)
    s = input |> mk_stat(0, n-1, 0)
    se = Nx.sqrt(Nx.divide(Nx.subtract(Nx.multiply(Nx.multiply(n, Nx.subtract(n, 1)), Nx.add(Nx.multiply(2,n), 5)),f), 18))
    z_score = z_stat(Nx.greater(s, 0) |> Nx.to_number, s, se)
    p_value = Nx.multiply(2, cdf(Nx.negate(Nx.abs(z_score))))
    trend = Nx.less(p_value, @alpha) |> Nx.to_number |> Arnold.Utilities.integer_to_boolean
    {n, @alpha, s, f, se, z_score, p_value, trend}
  end

  defp ties_correction(trend, n) do
    trend
    |> preliminary_ties_counts(0, n, [])
    |> ties_counts(trend, 0, n, [])
    |> frequency
    |> Nx.sum
  end

  defp preliminary_ties_counts(_trend, n, n, acc) do
    acc
    |> Nx.tensor
    |> Nx.reverse
  end

  defp preliminary_ties_counts(trend, k, n, acc) do
    v =
      trend[k]
      |> Nx.equal(trend[k+1..n])
      |> Nx.sum
      |> Nx.to_number
    preliminary_ties_counts(trend, k+1, n, [v | acc])
  end

  defp ties_counts(pre, trend, k, n, []) do
    ties_counts(pre, trend, k+1, n, [0])
  end

  defp ties_counts(_, _, n, n, acc) do
    acc |> Nx.tensor |> Nx.reverse
  end

  defp ties_counts(pre, trend, k, n, acc) do
    v =
      case trend[k] |> Nx.equal(trend[0..k-1]) |> Nx.sum |> Nx.to_number do
        0 -> pre[k] |> Nx.to_number
        _ -> 0
      end
    ties_counts(pre, trend, k+1, n, [v | acc])
  end

  defp frequency(tie) do
    tie
    |> Nx.not_equal(0)
    |> Nx.multiply(Nx.multiply(tie, Nx.multiply(Nx.add(tie, 1), Nx.add(Nx.multiply(tie, 2), 7))))
  end

  defp mk_stat(_trend, n, n, acc)  do
    acc
  end

  defp mk_stat(trend, k, n, acc) do
    c = trend[k]
    sum =
      trend[k+1..n]
      |> Nx.subtract(c)
      |> Nx.sign
      |> Nx.sum
    mk_stat(trend, k+1, n, Nx.add(sum, acc))
  end

  defp z_stat(1, s, se) do
    Nx.divide(Nx.subtract(s,1), se)
  end

  defp z_stat(0, s, se) do
    Nx.less(s, 0) |> Nx.multiply(Nx.divide(Nx.add(s,1), se))
  end

  defp cdf(z_stat) do
    z_stat
    |> Nx.divide(Nx.sqrt(2.0))
    |> Nx.erf
    |> Nx.add(1.0)
    |> Nx.divide(2.0)
  end

#  defp norm_inv(x, mean, sd) do
#    b =
#      x
#      |> Nx.subtract(mean)
#      |> Nx.power(2)
#      |> Nx.negate
#      |> Nx.divide(Nx.multiply(2, Nx.power(sd,2)))
#      |> Nx.exp
#    a = sd |> Nx.multiply(Nx.sqrt(Nx.multiply(2, :math.pi)))
#    Nx.divide(1,a) |> Nx.multiply(b)
#  end

#  defp strength(residual, data) do
#    v =
#      residual
#      |> variance
#      |> Nx.divide(variance(data))
#    Nx.max(0, Nx.subtract(1, v))
#  end


#  def find_peaks(x) do
#    n = Nx.size(x)-1
#    peaks(x,1,n,[])
#  end

#  def bartlett(x, k, n) do
#    se = Nx.divide(1, Nx.sqrt(n))
#    crit = norm_inv(1 - @alpha/2 |> Nx.tensor, 0, se)
#    acf = x[k-1]
#    p_value = Nx.subtract(1, cdf(acf))
#    case Nx.greater(acf, crit) |> Nx.to_number do
#      0 -> :no
#      1 -> :yes
#    end
#  end

#  defp peaks(_, n, n, acc) do
#    acc
#  end

#  defp peaks(x, i, n, acc) do
#    a =
#      case {Nx.greater(x[i], x[i-1]) |> Nx.to_number, Nx.greater(x[i], x[i+1]) |> Nx.to_number} do
#        {1,1} ->
#          [{i, x[i]} | acc]
#        _ -> acc
#      end
#    peaks(x, i+1, n, a)
#  end


end
