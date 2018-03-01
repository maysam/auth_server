Koala.configure do |config|
  # config.access_token = MY_TOKEN
  # config.app_access_token = MY_APP_ACCESS_TOKEN
  config.api_version = 'v2.12'
  config.app_id = ENV['FB_APP_ID'] || '169312520355618'
  config.app_secret = ENV['FB_APP_SECRET'] || '70a740355d71e01fdd4571a535f43988'
  # See Koala::Configuration for more options, including details on how to send requests through
  # your own proxy servers.
end