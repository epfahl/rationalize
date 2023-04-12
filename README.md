`Rationalize` uses the properties of the 
[Stern-Brocot](https://en.wikipedia.org/wiki/Stern%E2%80%93Brocot_tree) tree to 
generate controlled rational approximations to floating-point numbers.

# Usage

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
> r = Rationalize.closest_rational(3.1416, 100)
> r

%Rationalize.Rational{d: 99, n: 311}

> r |> Rationalize.Rational.to_float!()

3.141602634467618
```

It's also possible to find a pair of closest rational numbers `r1` and `r2` to
a float `x` such that `r1 <= x <= r2`:

```elixir
> Rationalize.closest_bracket(3.1416, 20)

[%Rationalize.Rational{d: 15, n: 47}, %Rationalize.Rational{d: 7, n: 22}]
```

# Stringitize!

One use-case for `Rationalize`--the one this tool was initially built for--is to provide
a more reader-friendly representation of floats when constructing quantitative narratives.
For example,

```elixir
> p = Rationalize.closest_rational(0.123, 10)
> "A catastrophic meltdown is expected to occur in roughly #{p.n} out of every #{p.d} reactors."

"A catastrophic meltdown is expected to occur in roughly 1 out of every 8 reactors."
```


