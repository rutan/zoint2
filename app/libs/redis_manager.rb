require 'redis'

module Zoint
  module RedisManager
    def self.init
      Redis.current = ConnectionPool.new({
        size: (ENV['REDIS_POOL_SIZE'] || 5).to_i,
        timeout: (ENV['REDIS_POOL_TIMEOUT'] || 5).to_i,
      }) do
        self.connect
      end
    end

    def self.with
      Redis.current.with do |redis|
        yield redis
      end
    end

    def self.connect
      url = ENV['REDISCLOUD_URL'] || 'redis://localhost'
      Redis.new(url: url)
    end
  end
end

