defmodule Rationalize.Rational do
  @moduledoc """
  Construct and _safely_ manipulate rational numbers.

  A rational number is defined by its integer numerator and denominator, each
  of which may be positive, negative, or zero. A denominator of 0 is
  perfectly acceptable for a rational number as long floating point
  division is avoided.
  """

  alias Rationalize.Rational, as: R

  @type t :: %R{
          n: integer(),
          d: integer()
        }

  defstruct [:n, :d]

  @type comparison :: :gt | :lt | :eq | :undefined
  @type option_float :: {:ok, float()} | :pos_infinity | :neg_infinity | :undefined

  @doc """
  Create a new `Rational` struct given integer values for the numerator and
  denominator. An exception is raised if the numerator or denominator is
  not an integer.
  """
  @spec new(integer(), integer()) :: R.t()
  def new(n, d) when is_integer(n) and is_integer(d) do
    %R{n: n, d: d}
  end

  @doc """
  Attempt to convert a rational number to a float.

  This returns `{:ok, <float value>}` for the given rational number if the
  denominator is nonzero. If the denominator is 0, this returns `:undefined`
  if the numerator is also 0, `:pos_inifinity` if the numerator is greater than
  0, or `:neg_infinity` if the numerator is less than 0.
  """
  @spec to_float(R.t()) :: option_float()
  def to_float(%R{n: 0, d: 0}), do: :undefined
  def to_float(%R{n: n, d: 0}) when n > 0, do: :pos_infinity
  def to_float(%R{n: n, d: 0}) when n < 0, do: :neg_infinity
  def to_float(%R{n: n, d: d}), do: {:ok, n / d}

  @doc ~S"""
  Return a string representation of a rational number using a provided format.

  The default format is "<numerator>/<denominator>", but this can be customized
  by providing a function that takes the numerator and denominator and returns
  a string.

  ## Examples

    iex> alias Rationalize.Rational, as: R
    iex> R.to_string(R.new(1, 2))
    "1/2"
    iex> R.to_string(R.new(1, 2), fn n, d -> "#{n} over #{d}" end)
    "1 over 2"
  """
  @spec to_string(R.t(), (integer(), integer() -> binary())) :: binary()
  def to_string(%R{n: n, d: d}, formatter \\ fn n, d -> "#{n}/#{d}" end) do
    formatter.(n, d)
  end

  @doc """
  Attempt to compute the difference between a rational number and a float.
  Arguments can be supplied in either order.

  This returns `{:ok, <float diff>}` when the rational can be converted to a
  finite float. If the denominator of the rational is 0, this returns
  `:undefined` if the numerator is also 0, `:pos_inifinity` if the numerator
  is greater than 0, or `:neg_infinity` if the numerator is less than 0.
  """
  @spec diff_num(R.t(), number()) :: option_float()
  def diff_num(%R{} = r, num) do
    case to_float(r) do
      {:ok, f} ->
        {:ok, f - num}

      other ->
        other
    end
  end

  @spec diff_num(number(), R.t()) :: option_float()
  def diff_num(num, %R{} = r) do
    case diff_num(r, num) do
      {:ok, d} -> {:ok, -d}
      :undefined -> :undefined
      :pos_infinity -> :neg_infinity
      :neg_infinity -> :pos_infinity
    end
  end

  @doc """
  Return the _mediant_ of two rational numbers. If `n1/d1` and `n2/d2` are two
  rational numbers, then

  `mediant(n1/d1, n2/d2) = (n1 + n2)/(d1 + d2)`

  The mediant has the property

  `n1/d1 < (n1 + n2)/(d1 + d2) < n2/d2`

  when `n1/d1 < n2/d2`.

  ## Examples

    iex> alias Rationalize.Rational, as: R
    iex> R.mediant(R.new(1, 4), R.new(1, 2))
    %R{n: 2, d: 6}
  """
  @spec mediant(R.t(), R.t()) :: R.t()
  def mediant(%R{n: n1, d: d1}, %R{n: n2, d: d2}) do
    new(n1 + n2, d1 + d2)
  end

  @doc """
  Negate a rational by negating the numerator. Note that this does the right
  thing when the denominator is 0.
  """
  @spec negate(R.t()) :: R.t()
  def negate(%R{n: n, d: d}), do: new(-n, d)

  @doc """
  Standardize a rational number such that the denominator is never negative.
  The result is numerically equivalent to the original rational, but not
  syntactically equivalent.

  ## Examples

    iex> alias Rationalize.Rational, as: R
    iex> R.standardize(R.new(1, 2))
    %R{n: 1, d: 2}
    iex> R.standardize(R.new(1, -2))
    %R{n: -1, d: 2}
  """
  @spec standardize(R.t()) :: R.t()
  def standardize(%R{n: n, d: d} = r) do
    if d < 0 do
      new(-n, -d)
    else
      r
    end
  end

  @doc """
  Compare a rational number to an ordinary number (integer or float). The
  result is `:gt`, `:lt`, or `:eq` if the rational is, respectively, greater
  than, less than, or equal to the float.

  The result is `:undefined` if the numerator and denominator of the rational
  are both 0.

  A rational with a denominator of 0 and a positive numerator is greater than
  any number. Similarly, a rational with a denominator of 0 and a negative
  numerator is less than any number.

  ## Examples

    iex> alias Rationalize.Rational, as: R
    iex> R.compare_to_num(R.new(1, 2), 1)
    :lt
  """
  @spec compare_to_num(R.t(), number()) :: comparison()
  def compare_to_num(%R{n: 0, d: 0}, _x), do: :undefined
  def compare_to_num(%R{n: n, d: 0}, _x) when n > 0, do: :gt
  def compare_to_num(%R{n: n, d: 0}, _x) when n < 0, do: :lt

  def compare_to_num(%R{} = r, x) do
    {:ok, f} = to_float(r)

    cond do
      f > x -> :gt
      f < x -> :lt
      f == x -> :eq
    end
  end

  @spec compare_to_num(number(), R.t()) :: comparison()
  def compare_to_num(num, %R{} = r) do
    case compare_to_num(r, num) do
      :gt -> :lt
      :lt -> :gt
      :eq -> :eq
      :undefined -> :undefined
    end
  end

  @doc """
  Compare two rational numbers. The result is `:gt`, `:lt`, or `:eq` if the
  first argument is, respectively, greater than, less than, or equal to the
  second argument. The comparison is done in a way that avoids conversion to
  a finite-precision float.

  The result is `:undefined` if one of the arguments has numerator and
  denominator equal to zero, or if both arguments have a denominator of 0.

  A rational with a denominator of 0 and a positive numerator is greater than
  any rational with a nonzero denominator. Similarly, a rational with a
  denominator of 0 and a negative numerator is less than any rational with a
  nonzero denominator.

  ## Examples

    iex> alias Rationalize.Rational, as: R
    iex> R.compare(R.new(1, 2), R.new(2, 1))
    :lt
    iex> R.compare(R.new(2, 1), R.new(1, 2))
    :gt
    iex> R.compare(R.new(1, 1), R.new(1, 1))
    :eq
    iex> R.compare(R.new(1, 0), R.new(1, 2))
    :gt
    iex> R.compare(R.new(-1, 0), R.new(-1, 2))
    :lt

  # Notes
    - While shortcuts may be possible, the explicit branches are easy to follow.
  """
  @spec compare(R.t(), R.t()) :: comparison()
  def compare(%R{n: 0, d: 0}, _r2), do: :undefined
  def compare(_r1, %R{n: 0, d: 0}), do: :undefined
  def compare(%R{n: n1, d: 0}, %R{n: n2, d: 0}) when n1 != 0 and n2 != 0, do: :undefined
  def compare(%R{n: n1, d: 0}, %R{d: d2}) when n1 > 0 and d2 != 0, do: :gt
  def compare(%R{n: n1, d: 0}, %R{d: d2}) when n1 < 0 and d2 != 0, do: :lt
  def compare(%R{d: d1}, %R{n: n2, d: 0}) when n2 > 0 and d1 != 0, do: :lt
  def compare(%R{d: d1}, %R{n: n2, d: 0}) when n2 < 0 and d1 != 0, do: :gt

  def compare(%R{} = r1, %R{} = r2) do
    # Standardize the rationals so that neither has a negative denominator,
    # then construct a comparator that only works with positive denominators.
    %R{n: n1, d: d1} = standardize(r1)
    %R{n: n2, d: d2} = standardize(r2)
    comp = n1 * d2 - n2 * d1

    cond do
      comp > 0 -> :gt
      comp < 0 -> :lt
      comp == 0 -> :eq
    end
  end
end
