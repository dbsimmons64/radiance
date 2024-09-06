# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :radiance,
  ecto_repos: [Radiance.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :radiance, RadianceWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RadianceWeb.ErrorHTML, json: RadianceWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Radiance.PubSub,
  live_view: [signing_salt: "oOd3HIHg"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :radiance, Radiance.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :radiance, repo: Radiance.Repo, endpoint: Radiance.Endpoint

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
