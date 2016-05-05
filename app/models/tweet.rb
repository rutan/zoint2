require 'date'
require 'json'
require 'mihatter'
require 'redis_manager.rb'

module Zoint
  class Tweet
    CHANNEL = 'tweet'
    KEYWORD = '(がんばるぞい OR 頑張るぞい) AND -RT'

    def self.crawl!
      Mihatter::RestWatcher.new({
        keyword: KEYWORD,
        lang: 'ja',
        since_id: self.since_id,
      }).run! do |tweet|
        next unless tweet.retweeted_status.kind_of?(Twitter::NullObject)
        date = tweet.created_at.to_date
        count = self.countup(date)
        self.since_id = tweet.id
        self.publish({
          type: 'tweet',
          count: count,
          date: date.to_s,
          tweet: {
            id: tweet.id,
            text: tweet.text,
            created_at: tweet.created_at,
            user: {
              name: tweet.user.screen_name,
              avatar_url: tweet.user.profile_image_url_https.to_s,
            }
          }
        })
      end
    rescue => e
      puts e.inspect
      puts e.backtrace
      sleep 60
      retry
    end

    def self.since_id
      since_id = nil
      RedisManager.with do |redis|
        since_id = redis.get('since_id').to_i
      end
      since_id > 0 ? since_id : nil
    end

    def self.since_id=(n)
      RedisManager.with do |redis|
        redis.set('since_id', n)
      end
    end

    def self.count(day = nil)
      day ||= Date.today
      RedisManager.with do |redis|
        redis.get("count::#{day.to_s}")
      end.to_i
    end

    def self.countup(day = nil)
      day ||= Date.today
      RedisManager.with do |redis|
        redis.incr("count::#{day.to_s}")
      end
    end

    def self.publish(data)
      RedisManager.with do |redis|
        redis.publish(CHANNEL, data.to_json)
      end
    end
  end
end
