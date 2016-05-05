require 'mihatter'

Mihatter.configuration do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.access_token = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
  config.wait_time = (ENV['WAIT_TIME'] || 30).to_i
end
