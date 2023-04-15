defmodule Rationalize.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :rationalize,
      name: "Rationalize",
      version: @version,
      elixir: "~> 1.14",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/epfahl/rationalize",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:stream_data, "~> 0.5", only: :test},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Rationalize provides tools for obtaining rational approximations and for working with rational numbers."
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Eric Pfahl"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/epfahl/rationalize"
      }
    ]
  end

  defp docs() do
    [
      main: "Tim",
      extras: ["README.md"]
    ]
  end
end
