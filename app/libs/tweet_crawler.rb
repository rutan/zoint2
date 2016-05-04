require 'twitter'

module Zoint
  class TweetCrawler
    def self.run!(config = {})
      crawler = self.new(config)
      begin
        crawler.connect
        crawler.assign_since_id unless crawler.since_id
        loop do
          crawler.fetch do |tweet|
            yield tweet
          end
          crawler.wait
        end
      rescue => e
        # TODO: 例外種類に応じた処理の変更
        puts e.inspect
        puts e.backtrace
        sleep 10
        retry
      end
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def initialize(config = {})
      @config = self.class.configuration.dup.merge(config)
      @since_id = @config.since_id
    end

    attr_reader :since_id

    def connect
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key = @config.consumer_key
        config.consumer_secret = @config.consumer_secret
        config.access_token = @config.access_token
        config.access_token_secret = @config.access_token_secret
      end
    end

    def fetch
      fetch_from_twitter.each do |result|
        yield result
        @since_id = result.id
      end
    end

    def wait
      sleep(@config.sleep_time)
    end

    def assign_since_id
      result = @client.search(@config.keywords, {
        result_type: 'recent',
        count: 1,
        lang: 'ja',
      }).first
      @since_id = (result ? result.id : 0)
    end

    private

    def fetch_from_twitter(max_id: nil)
      results = @client.search(@config.keywords, {
        result_type: 'recent',
        count: 100,
        lang: 'ja',
        max_id: max_id,
        since_id: @since_id
      }.delete_if {|_, v| v.nil?} ).take(100).reverse

      if @since_id && results.size == 100
        results += fetch_from_twitter(max_id: results.first.id)
      end

      results
    end

    class Configuration
      def initialize
        @sleep_time = 30
        @keywords = '寿司'
      end

      attr_accessor :consumer_key
      attr_accessor :consumer_secret
      attr_accessor :access_token
      attr_accessor :access_token_secret
      attr_accessor :keywords
      attr_accessor :sleep_time
      attr_accessor :since_id

      def merge(config = {})
        config.each do |k, v|
          self.public_send("#{k}=", v)
        end
        self
      end
    end
  end
end

