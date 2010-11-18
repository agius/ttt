require 'rubygems'
require 'sinatra'
require 'haml'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

require 'ttt'
run Sinatra.application