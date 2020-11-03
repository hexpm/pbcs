defmodule PBCS.MixProject do
  use Mix.Project

  def project do
    [
      app: :pbcs,
      version: "0.1.1",
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/hexpm/pbcs",
      docs: [extras: ["README.md"], main: "readme"],
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev}
    ]
  end

  defp description do
    "PKCS #5: Password-Based Cryptography Specification Version 2.0"
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      links: %{"Github" => "https://github.com/hexpm/pbcs"}
    ]
  end
end
