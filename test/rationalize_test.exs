defmodule RationalizeTest do
  @moduledoc """
  A sprinkle of property-based testing, mostly just to make sure no exceptions
  are raised due to missed edge cases.
  """

  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest Rationalize

  alias Rationalize, as: Rat

  property "integer inputs" do
    check all(n <- StreamData.integer()) do
      r = Rat.closest_rational(n, 10)
      assert r.n == n and r.d == 1
    end
  end

  property "float inputs" do
    check all(n <- StreamData.float(min: -10, max: -10)) do
      r = Rat.closest_rational(n, 10)
      assert n * r.n > 0
    end
  end
end
