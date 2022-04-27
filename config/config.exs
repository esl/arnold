# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
import Config

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

config :arnold,
  port: 8081

import_config "#{config_env()}.exs"
