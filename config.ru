require 'rubygems'
require 'vendor/sinatra/lib/sinatra.rb'
require 'vendor/haml/lib/haml.rb'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

require 'ttt'
run Sinatra.application