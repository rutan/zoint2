# coding:utf-8

require 'bundler'
Bundler.require

$stdout.sync = true
Dotenv.load

Dir.glob(File.expand_path('../app/*', __FILE__)).to_a.sort.each do |path|
  $: << path
end
Dir.glob(File.expand_path('../config/initializers/**/*.rb', __FILE__)).to_a.sort.each do |path|
  require path
end

# middlewares
require 'thread_launcher.rb'
use Zoint::ThreadLauncher if ENV['NO_CRAWLER'].to_i == 0

require 'websocket.rb'
use Zoint::WebSocket

# launch application
require './app.rb'
run Zoint::App

