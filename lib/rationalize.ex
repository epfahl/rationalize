defmodule Rationalize do
  @moduledoc """
  Run the following to find a rational approximation to 3.1416 with a maximum
  denominator of 20:

  ```elixir
  > Rationalize.closest_rational(3.1416, 20)

  %Rationalize.Rational{d: 7, n: 22}
  ```

  This returns a struct that represents the rational number 22/7. The float
  representation of this struct is

  ```elixir
  > %Rationalize.Rational{d: 7, n: 22} |> Rationalize.Rational.to_float!()

  3.142857142857143
  ```

  The accuracy of the approximation is controlled by the maximum
  denominator. Setting the maximum denominator too 1000, we find

  ```elixir
  > r = Rationalize.closest_rational(3.1416, 1000)
  > r

  %Rationalize.Rational{d: 99, n: 311}

  > r |> Rationalize.Rational.to_float!()

  3.141602634467618
  ```
  """

  alias Rationalize.Rational, as: R

  @doc """
  Return the rational fraction closest to the float `x`, such that the rational has a
  denominator less than `den_max`.

  ## Examples

      iex> Rationalize.closest_rational(0.27, 10) |> Rationalize.Rational.to_string()
      "2/7"

      iex> Rationalize.closest_rational(3.14159265359, 20) |> Rationalize.Rational.to_string()
      "22/7"
  """
  def closest_rational(x, den_max) do
    [b1, b2] = closest_bracket(x, den_max)
    [f1, f2] = bracket_to_floats([b1, b2])
    if x - f1 < f2 - x, do: b1, else: b2
  end

  @doc """
  Return the bracket of rational numbers `[r1, r2]` that most closely bounds the
  float `x`, such that both rational numbers in the bracket have denominators less
  than `den_max`.

  This assumes that the initial bracket is chosen to be a pair of adjacent values in
  the Stern-Brocot tree.

  ## Examples

      iex> Rationalize.closest_bracket(0.27, 10) |> Enum.map(&Rationalize.Rational.to_string/1)
      ["1/4", "2/7"]

      iex> Rationalize.closest_bracket(3.14159265359, 20) |> Enum.map(&Rationalize.Rational.to_string/1)
      ["47/15", "22/7"]

  """
  def closest_bracket(x, den_max) when is_number(x) and is_integer(den_max) and den_max > 0 do
    converge(init_bracket(x), x, den_max)
  end

  @doc """
  Recursively narrow the bracket around `x` until the halting condition is satisfied.
  """
  def converge(bracket, x, den_max) do
    case update_bracket(bracket, x, den_max) do
      {:cont, b} -> converge(b, x, den_max)
      {:halt, b} -> b
    end
  end

  @doc """
  Return `{message, bracket}`, where `message` is either `:cont`, indicating that
  convergence should continue, or `:halt`, indicating that convergence should stop.
  The updated bracket is obtained by replacing the smaller (larger) rational number
  with the mediant if the mediant is less than (greather than) `x`.

  The halting condition is satisfied when:
  1) either end of the intput bracket equal `x`.
  2) the denominator of the updated mediant is greater than `den_max`.
  3) the value of the next mediant equals `x`.

  This is the key to the algorithm that causes the bracket to converge toward the
  target float.

  ## Examples

      iex> Rationalize.update_bracket([Rationalize.Rational.new(0, 1), Rationalize.Rational.new(1, 1)], 0.27, 10)
      {:cont, [%Rationalize.Rational{d: 1, n: 0}, %Rationalize.Rational{d: 2, n: 1}]}
  """
  def update_bracket([%R{} = b1, %R{} = b2] = bracket, x, den_max) do
    [f1, f2] = bracket_to_floats(bracket)

    if f1 == x or f2 == x do
      {:halt, bracket}
    else
      m = R.mediant(b1, b2)
      f = R.to_float!(m)

      cond do
        f > x and m.d <= den_max -> {:cont, [b1, m]}
        x > f and m.d <= den_max -> {:cont, [m, b2]}
        m.d > den_max -> {:halt, bracket}
        f == x -> {:halt, [m, m]}
      end
    end
  end

  @doc """
  Initialize the bracket around float `x` as `[floor(x) / 1, ceil(x) / 1]`. This
  initalization ensures that the rational pairs generated through mediant iteration
  satisfy `d1 n2 - d2 n1 = 1`.
  """
  def init_bracket(x) do
    [R.new(floor(x), 1), R.new(ceil(x), 1)]
  end

  @doc """
  Return the bracket of rationals as a bracket of corresponding floats.
  """
  def bracket_to_floats(bracket) do
    bracket |> Enum.map(&R.to_float!/1)
  end
end
