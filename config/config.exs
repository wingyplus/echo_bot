import(Mix.Config)

config :echo_bot, line_secret_key: "---secret-key---"

import_config "#{Mix.env()}.exs"
