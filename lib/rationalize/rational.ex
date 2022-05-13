defmodule Rationalize.Rational do
  @moduledoc """
  Define rational numbers via a struct, such that `n/d -> %Rational{n: n, d: d}`.
  This module is meant only to serve the needs of `Florat` and is not a general library
  for working with rational numbers.

  Todo:
  * Add type specs.
  """

  defstruct n: 0, d: 1

  alias __MODULE__, as: R

  @doc """
  Create a new `Rational` struct given integer values for the numerator and denominator.
  """
  def new(n, d) when is_integer(n) and is_integer(d) do
    %R{n: n, d: d}
  end

  @doc """
  Return a string representation of a `Rational`. The default formatting is `n/d`, but
  this can be customized with a `formatter` funciton that takes the numerator and
  denominator and returns a string.
  """
  def to_string(
        %R{n: n, d: d},
        formatter \\ fn n, d -> "#{n}/#{d}" end
      ) do
    formatter.(n, d)
  end

  @doc """
  Return the float value of the given `Rational`. An exception is raised if the
  denominator equals 0.
  """
  def to_float!(%R{n: n, d: d}) do
    n / d
  end

  @doc """
  Return the _mediant_ of two rational numbers, defined as

  `mediant(n1/d1, n2/d2) = (n1 + n2)/(d1 + d2)`

  which has the property

  `n1/d1 < (n1 + n2)/(d1 + d2) < n2/d2`

  when `n1/d1 < n2/d2`.
  """
  def mediant(%R{n: n1, d: d1}, %R{n: n2, d: d2}) do
    new(n1 + n2, d1 + d2)
  end
end
