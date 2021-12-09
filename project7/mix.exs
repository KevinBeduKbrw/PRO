defmodule Project2.MixProject do
  use Mix.Project

  def project do
    [
      app: :tutokbrwstack,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      compilers: [:reaxt_webpack] ++ Mix.compilers,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl,
     :reaxt],

      mod: {TutoKBRWStack, []}
      #mod: {TutoElixirKBRW, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 2.1.0"},
      {:reaxt, tag: "2.1.0", github: "kbrw/reaxt"},
      {:rulex, git: "https://github.com/kbrw/rulex.git"},
      {:exfsm, git: "https://github.com/kbrw/exfsm.git"},
      {:plug_cowboy, "~> 1.0.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
