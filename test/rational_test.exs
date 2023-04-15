defmodule RationaleTest do
  use ExUnit.Case, async: true
  doctest Rationalize.Rational

  alias Rationalize.Rational, as: R

  test "mediant of two rationals" do
    r1 = R.new(1, 2)
    r2 = R.new(3, 4)
    r3 = R.new(0, 1)
    r4 = R.new(1, 0)
    r5 = R.new(1, -2)

    assert R.mediant(r1, r2) == %R{n: 4, d: 6}
    assert R.mediant(r1, r3) == %R{n: 1, d: 3}
    assert R.mediant(r1, r4) == %R{n: 2, d: 2}
    assert R.mediant(r1, r5) == %R{n: 2, d: 0}
  end

  test "rational to float" do
    r1 = R.new(1, 2)
    r2 = R.new(1, 0)
    r3 = R.new(-1, 0)
    r4 = R.new(0, 0)

    assert R.to_float(r1) == {:ok, 0.5}
    assert R.to_float(r2) == :pos_infinity
    assert R.to_float(r3) == :neg_infinity
    assert R.to_float(r4) == :undefined
  end

  test "difference between a rational and a float" do
    r1 = R.new(3, 2)
    r2 = R.new(-3, 2)
    r3 = R.new(1, 0)
    r4 = R.new(-1, 0)
    r5 = R.new(0, 0)

    assert R.diff_num(r1, 1) == {:ok, 0.5}
    assert R.diff_num(r2, 1) == {:ok, -2.5}
    assert R.diff_num(1, r1) == {:ok, -0.5}
    assert R.diff_num(r3, 1) == :pos_infinity
    assert R.diff_num(r4, 1) == :neg_infinity
    assert R.diff_num(1, r3) == :neg_infinity
    assert R.diff_num(r5, 1) == :undefined
    assert R.diff_num(1, r5) == :undefined
  end

  test "compare a rational and a float" do
    r1 = R.new(3, 2)
    r2 = R.new(-3, 2)
    r3 = R.new(1, 0)
    r4 = R.new(-1, 0)
    r5 = R.new(0, 0)

    assert R.compare_to_num(r1, 1) == :gt
    assert R.compare_to_num(r2, 1) == :lt
    assert R.compare_to_num(1, r1) == :lt
    assert R.compare_to_num(r1, 1.5) == :eq
    assert R.compare_to_num(1.5, r1) == :eq
    assert R.compare_to_num(r3, 1) == :gt
    assert R.compare_to_num(1, r3) == :lt
    assert R.compare_to_num(r4, 1) == :lt
    assert R.compare_to_num(r5, 1) == :undefined
    assert R.compare_to_num(1, r5) == :undefined
  end

  test "compare with 0/0 (undefined)" do
    r1 = R.new(0, 0)
    r2 = R.new(1, 2)

    assert R.compare(r1, r2) == :undefined
    assert R.compare(r2, r1) == :undefined
  end

  test "compare when both have denominator 0" do
    r1 = R.new(1, 0)
    r2 = R.new(2, 0)

    assert R.compare(r1, r2) == :undefined
  end

  test "compare with n / 0, n > 0" do
    r1 = R.new(1, 0)
    r2 = R.new(1, 2)

    assert R.compare(r1, r2) == :gt
    assert R.compare(r2, r1) == :lt
  end

  test "compare with n / 0, n < 0" do
    r1 = R.new(-2, 0)
    r2 = R.new(1, 2)

    assert R.compare(r1, r2) == :lt
    assert R.compare(r2, r1) == :gt
  end

  test "compare nonzero denominator" do
    r1 = R.new(1, 2)
    r2 = R.new(2, 1)
    r3 = R.new(-2, 1)
    r4 = R.new(2, 4)
    r5 = R.new(1, -2)

    assert R.compare(r1, r2) == :lt
    assert R.compare(r2, r1) == :gt
    assert R.compare(r3, r1) == :lt
    assert R.compare(r1, r1) == :eq
    assert R.compare(r4, r1) == :eq
    assert R.compare(r5, r1) == :lt
    assert R.compare(r1, r5) == :gt
    assert R.compare(r3, r5) == :lt
  end

  test "standardize" do
    r1 = R.new(1, -2)
    r2 = R.new(0, -1)
    r3 = R.new(1, 2)
    r4 = R.new(1, 0)

    assert R.standardize(r1) == %R{n: -1, d: 2}
    assert R.standardize(r2) == %R{n: 0, d: 1}
    assert R.standardize(r3) == %R{n: 1, d: 2}
    assert R.standardize(r4) == %R{n: 1, d: 0}
  end

  test "compare to number" do
    r1 = R.new(1, 2)
    r2 = R.new(1, 0)
    r3 = R.new(-1, 0)
    r4 = R.new(0, 0)
    r5 = R.new(1, 1)

    assert R.compare_to_num(r1, 1) == :lt
    assert R.compare_to_num(r2, 1) == :gt
    assert R.compare_to_num(r3, 1) == :lt
    assert R.compare_to_num(r4, 1) == :undefined
    assert R.compare_to_num(r5, 1) == :eq
  end
end
