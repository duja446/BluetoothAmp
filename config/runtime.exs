import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  mpd_ip = 
    System.get_env("MPD_IP") ||
      raise """
        environment variable MPD_IP not set
        """
  mpd_port = 
    System.get_env("MPD_PORT") ||
      raise """
        environment variable MPD_PORT not set
        """

  config :player, 
    mpd_ip: 
      mpd_ip
      |> String.split(".")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple(),
    mpd_port: String.to_integer(mpd_port)

  file_server =
    System.get_env("FILE_SERVER_IP") ||
      raise """
        environment variable FILE_SERVER_IP not set
        """

  youtube_api_key = 
    System.get_env("YOUTUBE_API_KEY") ||
      raise """
        environment variable YOUTUBE_API_KEY not set
        """

  config :bluetooth_amp_web, 
    file_server: file_server,
    youtube_api_key: youtube_api_key

  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      environment variable DATABASE_PATH is missing.
      For example: /etc/bluetooth_amp/bluetooth_amp.db
      """

  config :bluetooth_amp, BluetoothAmp.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :bluetooth_amp_web, BluetoothAmpWeb.Endpoint,
    url: [
      host: System.get_env("HOST") || "localhost", 
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
       config :bluetooth_amp_web, BluetoothAmpWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
