`Rationalize` can find a close rational approximation to any decimal number. 
This library also provides a small, incomplete tool set for working with
rational numbers.

# Basic usage

Find the closest rational approximation to 0.17 with a denominator no larger 
than 10:

```elixir
> Rationalize.closest_rational(0.17, 10)
%Rationalize.Rational{n: 1, d: 6}
```

Notice that the function `closest_rational` returns a struct with fields 
`n` and `d` that hold the numerator and denominator, respectively.

A rational number can be converted to a float or a string:

```elixir
> Rationalize.to_float(%Rationalize.Rational{n: 1, d: 6})
{:ok, 0.16666666666666666}

> Rationalize.to_string(%Rationalize.Rational{n: 1, d: 6})
"1/6"
```

The precision of the rational approximation can be increased by increasing
the maximum denominator:

```elixir
> Rationalize.closest_rational(0.17, 100)
%Rationalize.Rational{n: 17, d: 100}
```

This last result is exact. Further increase in the maximum denominator will not
change the result:

```elixir
> Rationalize.closest_rational(0.17, 1000)
%Rationalize.Rational{n: 17, d: 100}
```

# Advanced usage

Working with rational numbers _safely_ means avoiding conversion to floating 
numbers unless it's necessary, properly handling cases where the
numerator or denominator may be 0, and allowing the numerator or denominator 
to be negative. The module `Rationalize.Rational` provides a small set of safe 
operations:

```elixir
# Compare two rational numbers
> r1 = Rationalize.Rational.new(1, 0)
> r2 = Rationalize.Rational.new(1, 2)
> Rationalize.Rational.compare(r1, r2)
:gt   # r1 > r2

# Compute the numerical difference between a rational and a float
> r3 = Rationalize.Rational.new(3, 2)
> Rationalize.Rational.diff_num(r3, 0.5)
{:ok, 1.0}

# Operations with negative rationals are allows
> r4 = Rationalize.Rational.new(-3, 2)
> Rationalize.Rational.diff_num(r4, 0.5)
{:ok, -2.0}

# A difference can return :pos_infinity or :neg_infinity
> r5 = Rationalize.Rational.new(-1, 0)
> Rationalize.Rational.diff_num(0.5, r5)
:pos_infinity

# Any operations with 0/0 return :undefined
> r6 = Rationalize.Rational.new(0, 0)
> Rationalize.Rational.diff_num(r6, 1)
:undefined
```

The utilities in `Rationalize.Rational` were originally built only to support 
the search for rational approximations. But they have general applicability, 
and the tool set could be expanded in the future.

# Use cases

`Rationalize` was originally developed for two very specific use cases.

## Probabilities as fractions

When a probability is presented in decimal form, it may be challenging for some
readers to create a mental model of what that probability might _mean_. For 
example, a decimal probability could be presented like this in a short
narrative:

> The chance of a catastrophic meltdown is 0.17.

But it might be preferable to write this:

> The chance of a catastrophic meltdown is 1 in 6.

## Rational approximations

It's sometimes computationally convenient to have a rational approximation of
a decimal number. With a number like `pi = 3.14159265359...` it might be handy
to remember that 22/7 is a reasonably close approximation (about 3.143).

# How does it work?

`Rationalize` uses a nice bit of math to find close rational approximations. The
[Stern-Brocot](https://en.wikipedia.org/wiki/Stern%E2%80%93Brocot_tree) tree
is a binary tree that holds all positive rational numbers whose numerator and
denominator are relatively prime (no common factors). To find a rational 
approximation to a decimal number, a binary search is used to navigate the
tree until some termination condition is satisfied.

Each update of the binary search uses the _mediant_ of two rational numbers. 
If `R1 = n1/d1` and `R2 = n2/d2` are two rational numbers, and `R1 < R2`,
the mediant is `M = (n1 + n2) / (d1 + d2)`, which has the property
`R1 < M < R2`. For a target decimal `d` and `R1 < d < R2`, the mediant
is used to recursively narrow the range of the bracketing rationals.

Because of the properties of the Stern-Brocot tree and the mediant-based search, 
the rational returned by `closest_rational` will always have relatively
prime numerator and denominator.


# Todo

`Rationalize` grew from a specific use case, but it could be generalized to
be a more complete library for working with rational numbers. Possibilities
for extending `Rationalize` include

- adaptively computing the maximum denominator based on the size of the decimal.
- adding more utilities for working with rational numbers (e.g., add, multiply, 
  divide, subtract), and bringing these into the top-level API.