defmodule PBCS.MixProject do
  use Mix.Project

  def project do
    [
      app: :pbcs,
      version: "0.1.0",
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/hexpm/pbcs",
      docs: [extras: ["README.md"], main: "readme"],
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      links: %{"Github" => "https://github.com/hexpm/pbcs"}
    ]
  end
end
