# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :web_interface_web,
  namespace: WebInterfaceWeb

# Configures the endpoint
config :web_interface_web, WebInterfaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0i6Gc5j6mZtHOiXFcCJhtnoCNbhIy9wU1yyXtE8cxJLhogTnLb2WbPBH/BpYFmSm",
  render_errors: [view: WebInterfaceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WebInterfaceWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :web_interface_web, :generators,
  context_app: :web_interface

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
