defmodule PushPool.Mixfile do
  use Mix.Project

  def project do
    [app: :push_pool,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :poolboy, :pushito],
     mod: {PushPool, []}]
  end

  defp deps do
    [{:poolboy, "~> 1.5"},
     {:pushito, "~> 0.1.1"}]
  end
end
