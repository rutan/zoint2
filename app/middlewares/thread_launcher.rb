require 'tweet.rb'

module Zoint
  class ThreadLauncher
    def initialize(app)
      @app = app
      launch
    end

    def call(env)
      @app.call(env)
    end

    def launch
      @threads = []
      @threads.push(Thread.new do
        Zoint::Tweet.crawl!
      end)
    end
  end
end

