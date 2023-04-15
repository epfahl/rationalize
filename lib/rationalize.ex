defmodule Rationalize do
  @moduledoc File.read!("README.md")

  defdelegate closest_rational(num, den_max), to: Rationalize.Search, as: :closest_rational

  defdelegate to_string(r), to: Rationalize.Rational, as: :to_string

  defdelegate to_string(r, formatter), to: Rationalize.Rational, as: :to_string

  defdelegate to_float(r), to: Rationalize.Rational, as: :to_float
end
