require 'date'
require 'json'
require 'redis_manager.rb'

module Zoint
  class Tweet
    CHANNEL = 'tweet'
    KEYWORDS = '(がんばるぞい OR 頑張るぞい OR 今日も一日がんばるぞい OR 今日も一日頑張るぞい OR 今日も1日がんばるぞい OR 今日も1日頑張るぞい) AND -RT'

    def self.crawl!
      TweetCrawler.run!({
        keywords: KEYWORDS,
        since_id: self.since_id,
      }) do |result|
        next unless result.retweeted_status.kind_of?(Twitter::NullObject)
        count = self.countup.inspect
        self.since_id = result.id
        self.publish({
          type: 'tweet',
          count: count,
          tweet: {
            id: result.id,
            text: result.text,
            user: {
              name: result.user.screen_name,
              avatar_url: result.user.profile_image_url_https.to_s,
            }
          }
        })
      end
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

