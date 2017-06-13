defmodule Pushito.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [app: :pushito,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     docs: docs(),
     description: description(),
     package: package()
    ]
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
     {:credo, "~> 0.7.4", only: [:dev, :test]},

     # Docs
     {:ex_doc, "~> 0.16.1", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [source_ref: "v#{@version}",
     main: "Pushito",
     canonical: "http://hexdocs.pm/pushito",
     source_url: "https://github.com/inaka/pushito",
     extras: ["guides/Convert cer to pem.md"]]
  end

  defp description do
    """
    APNs provider for Apple Push Notification services (APNs) in Elixir. It supports the HTTP2 API.
    """
  end

  defp package do
    [
      name: :pushito,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Inaka"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/inaka/pushito"}
    ]
  end
end
