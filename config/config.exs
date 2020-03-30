import(Mix.Config)

config :echo_bot,
  line_secret_key: "---secret-key---",
  line_access_token: "---access-token---"

import_config "#{Mix.env()}.exs"
