defmodule Rationalize.Search do
  @moduledoc """
  Implementation of the search strategy for neaby rational numbers that bracket
  a given number.

  The search for the bracketing rationals involves a traversal of the
  Stern-Brocot tree. Since the Stern-Brocot tree is essentially a binary tree,
  the search amounts to a binary search.

  Every node in the Stern-Brocot tree is a rational number with relatively
  prime numerator and denominator (no common factors). It follows that each
  rational that brackets `num` has relatively prime components and cannot
  be further reduced.
  """

  alias Rationalize.Rational, as: R

  @type bracket :: {R.t(), R.t()}

  @doc """
  Return the rational fraction closest to the number `num` with denominator
  no larger than integer `den_max`.

  ## Examples

      iex> Rationalize.closest_rational(0.27, 10)
      %Rationalize.Rational{n: 2, d: 7}
  """
  @spec closest_rational(number(), pos_integer()) :: R.t()
  def closest_rational(0, _den_max), do: R.new(0, 1)

  def closest_rational(num, den_max) when is_number(num) and is_integer(den_max) do
    {r1, r2} = closest_bracket(num, den_max)

    # CHECK ME: I think it's safe to assume `closest_bracket` never returns a
    # rational with denominator 0 when `num` != 0.
    {:ok, diff_left} = R.diff_num(num, r1)
    {:ok, diff_right} = R.diff_num(r2, num)
    if diff_left < diff_right, do: r1, else: r2
  end

  @doc """
  Return the bracket of rational numbers `{r1, r2}` that most closely bounds
  the number `num`, such that both rationals have denominators no larger than
  integer `den_max`.

  ## Examples

      iex> Rationalize.Search.closest_bracket(0.27, 10)
      {%Rationalize.Rational{n: 1, d: 4}, %Rationalize.Rational{n: 2, d: 7}}

  """
  @spec closest_bracket(number(), pos_integer()) :: bracket
  def closest_bracket(num, den_max) when is_number(num) and is_integer(den_max) and den_max > 0 do
    # Find the positive rationals that bracket the absolute value of the input number.
    {r1, r2} =
      {R.new(0, 1), R.new(1, 0)}
      |> search(abs(num), den_max)

    # If the input number is negative, flip the order and negate the bracketing rationals.
    if num < 0 do
      {R.negate(r2), R.negate(r1)}
    else
      {r1, r2}
    end
  end

  @doc """
  Recursively narrow the rational bracket around number `num` until one of the
  termination conditions is satisfied.

  The search terminates when:
    1. either end of the input bracket numerically equals `num`.
    2. the denominator of the mediant of the input bracket exceeds `den_max`.
    3. the mediant of the input bracket equals `num`.
  """
  def search({%R{} = r1, %R{} = r2} = bracket, num, den_max) when num >= 0 do
    c1 = R.compare_to_num(r1, num)
    c2 = R.compare_to_num(r2, num)

    if :eq in [c1, c2] do
      # Return the bracket if either rational equals `num`.
      bracket
    else
      # Compute the mediant and either return or narrow the bracket and recurse.
      m = R.mediant(r1, r2)
      cm = R.compare_to_num(m, num)

      cond do
        m.d > den_max ->
          # Return the bracket if the denominator of the mediant exceeds the max.
          bracket

        cm == :eq ->
          # If the mediant equals `num`, collapse the bracket and return.
          {m, m}

        cm == :gt ->
          search({r1, m}, num, den_max)

        cm == :lt ->
          search({m, r2}, num, den_max)
      end
    end
  end
end
