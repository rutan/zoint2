require 'sinatra/base'

module Zoint
  class App < Sinatra::Application
    get '/' do
      slim :index, locals: {
        count: zoi_count
      }
    end

    get '/zoi.json' do
      dates = Array.new(7).map.with_index do |_, i|
        date = Date.today - i
        [date, zoi_count(date)]
      end.to_h
      {
        today: zoi_count,
        zoi: dates,
        timestamp: Time.now.to_i,
      }.to_json
    end

    get '/zoi/:date.json' do
      puts params[:date]
      return 404 unless params[:date].to_s.match(/\A20[1-9][0-9]-[0-1][0-9]-[0-3][0-9]\z/)
      begin
        date = Date.parse(params[:date])
        {
          date: date.to_s,
          total: zoi_count(date),
          timestamp: Time.now.to_i,
        }.to_json
      rescue ArgumentError => _e
        return 404
      end
    end

    def zoi_count(date = nil)
      Zoint::Tweet.count(date)
    end
  end
end

