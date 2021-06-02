defmodule PBCS.MixProject do
  use Mix.Project

  @version "0.1.4"
  @source_url "https://github.com/hexpm/pbcs"

  def project do
    [
      app: :pbcs,
      version: @version,
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @source_url,
      docs: [source_ref: "v#{@version}", main: "readme", extras: ["README.md"]],
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:crypto]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end

  defp description do
    "PKCS #5: Password-Based Cryptography Specification Version 2.0"
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/hexpm/pbcs"}
    ]
  end
end
