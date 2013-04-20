require 'rubygems'
require 'bundler'

# Set default environment to development
ENV['RACK_ENV'] = "development" unless ENV['RACK_ENV']
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

# Require all .rb files in app/
Dir["./app/*/*.rb"].each { |file| require file }

Mongoid.load!("config/mongoid.yml")
require "./datashare_filter"
