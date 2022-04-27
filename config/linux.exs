# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config


# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
# and access this configuration in your application as:
#
#     Application.get_env(:arnold, :key)
#
# You can also configure a third-party app:
#
config :logger,
       backends: [{LoggerFileBackend, :info_log}, {LoggerFileBackend, :warning_log}, {LoggerFileBackend, :error_log}],
       truncate: :infinity

config :logger, :info_log,
       path: "var/log/info.log",
       level: :info,
       truncate: :infinity

config :logger, :warning_log,
       path: "var/log/warning.log",
       level: :warning,
       truncate: :infinity

config :logger, :error_log,
       path: "var/log/error.log",
       level: :error,
       truncate: :infinity

config :mnesia,
       dir: '.mnesia/data/',
       dump_log_write_threshold: 5000
