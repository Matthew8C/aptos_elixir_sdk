defmodule Aptos.MixProject do
  use Mix.Project

  def project do
    [
      app: :aptos,
      version: "0.2.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Aptos",
      description: "Aptos SDK for Elixir",
      package: package(),
      source_url: "https://github.com/Matthew8C/aptos_elixir_sdk",
      docs: docs()
    ]
  end

  defp package do
    [
      name: :aptos,
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/Matthew8C/aptos_elixir_sdk"},
      maintainers: ["Matthew A. C."]
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "master"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Aptos.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29.1", only: :dev, runtime: false},
      {:tesla, "~> 1.5"},
      {:finch, "~> 0.14.0"},
      {:castore, "~> 0.1.22"},
      {:jason, "~> 1.4"},
      {:bcs, "~> 0.1.0", hex: :ex_bcs},
      {:nimble_parsec, "~> 1.2"}
    ]
  end
end
