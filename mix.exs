defmodule Pushito.Mixfile do
  use Mix.Project

  def project do
    [app: :pushito,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :chatterbox, :poison, :joken],
     mod: {Pushito, []}]
  end

  defp deps do
    [{:chatterbox, "~> 0.4.2"},
     {:poison, "~> 3.1"},
     {:joken, "~> 1.4"},

     # Code Analysis
     {:dialyxir, "~> 0.5", only: :dev, runtime: false},
     {:credo, "~> 0.7.4", only: [:dev, :test]}
    ]
  end
end
