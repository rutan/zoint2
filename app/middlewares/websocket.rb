require 'faye/websocket'
require 'json'
require 'redis_manager.rb'
require 'tweet.rb'

module Zoint
  class WebSocket
    KEEPALIVE_TIME = 15

    def initialize(app)
      @app     = app
      @clients = []
      deliver
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          @clients << ws
        end

        ws.on :message do |event|
          ws.send({type: 'ping', message: 'pong'}.to_json)
        end

        ws.on :close do |event|
          @clients.delete(ws)
          ws = nil
        end

        ws.rack_response
      else
        @app.call(env)
      end
    end

    def deliver
      Thread.new do
        begin
          redis = Zoint::RedisManager.connect
          redis.subscribe(Zoint::Tweet::CHANNEL) do |on|
            on.message do |_channel, msg|
              @clients.each {|ws| ws.send(msg) }
            end
          end
        rescue => e
          puts e.inspect
          puts e.backtrace
          sleep 1
        end
      end
    end
  end
end
