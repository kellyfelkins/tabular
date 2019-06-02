defmodule Tabular.MixProject do
  use Mix.Project

  def project do
    [
      app: :tabular,
      version: "0.1.0",
      elixir: "~> 1.8",
      deps: deps(),
      name: "Tabular",
      source_url: "https://github.com/kellyfelkins/tabular",
      homepage_url: "https://github.com/kellyfelkins/tabular",
      docs: [
        main: "Tabular",
        extras: ["README.md"]
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
