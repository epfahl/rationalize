defmodule SearchTest do
  use ExUnit.Case, async: true
  doctest Rationalize.Search

  alias Rationalize.Search, as: S
  alias Rationalize.Rational, as: R

  test "closest bracket 0" do
    assert S.closest_bracket(0, 1) == {%R{n: 0, d: 1}, %R{n: 1, d: 0}}
  end

  test "closest bracket integer" do
    assert S.closest_bracket(1, 1) == {%R{n: 1, d: 1}, %R{n: 1, d: 1}}
    assert S.closest_bracket(2, 1) == {%R{n: 2, d: 1}, %R{n: 2, d: 1}}
  end

  test "closest bracket float" do
    assert S.closest_bracket(:math.sqrt(2), 10) == {%R{n: 7, d: 5}, %R{n: 10, d: 7}}
    assert S.closest_bracket(:math.pi(), 10) == {%R{n: 25, d: 8}, %R{n: 22, d: 7}}
  end

  test "closest bracket negative integer" do
    assert S.closest_bracket(-1, 1) == {%R{n: -1, d: 1}, %R{n: -1, d: 1}}
    assert S.closest_bracket(-2, 1) == {%R{n: -2, d: 1}, %R{n: -2, d: 1}}
  end

  test "closest bracket negative float" do
    assert S.closest_bracket(-:math.sqrt(2), 10) == {%R{n: -10, d: 7}, %R{n: -7, d: 5}}
    assert S.closest_bracket(-:math.pi(), 10) == {%R{n: -22, d: 7}, %R{n: -25, d: 8}}
  end
end
