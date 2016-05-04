require 'tweet_crawler.rb'

Zoint::TweetCrawler.configuration.tap do |config|
  config.consumer_key = ENV['CONSUMER_KEY']
  config.consumer_secret = ENV['CONSUMER_SECRET']
  config.access_token = ENV['access_token']
  config.access_token_secret = ENV['access_token_secret']
end

