defmodule Arnold.MixProject do
  use Mix.Project

  def project do
    [
      app: :arnold,
      version: "0.6.2",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :dev,
      deps: deps(),
      name: "Arnold",
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Arnold.Application, []},
      extra_applications: [:logger, :logger_file_backend]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:memento, "~> 0.3.2"},
      {:httpoison, "~> 1.8"},
      {:plug_cowboy, "~> 2.5"},
      {:poison, "~> 5.0"},
      {:axon, "~> 0.1.0-dev", github: "elixir-nx/axon", branch: "main"},
      {:nx, "~> 0.2.0-dev", github: "elixir-nx/nx", sparse: "nx", override: true},
      {:logger_file_backend, "~> 0.0.11"},
      {:uuid, "~> 1.1"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:distillery, "~> 2.1"},
      {:ex_doc, "~> 0.24", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      main: "Arnold", # The main page in the docs
      logo: "assets/logo.png"
    ]
  end

  defp package do
    [
      maintainers: ["Tamás Lengyel", "Mohamed Ali Khechine"],
      organization: "Erlang Solutions Ltd.",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/esl/arnold"}
    ]
  end
end
