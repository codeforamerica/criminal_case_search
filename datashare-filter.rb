#TODO: rename with underscores
require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)
require './helpers/arrest_report_helper.rb'

class DatashareFilter < Sinatra::Base
  include Mongo
  register Sinatra::Twitter::Bootstrap::Assets

  configure do
    set :haml, :format => :html5

    client = MongoClient.new("localhost", 27017)
    set :mongo_client, client
    set :db, client.db('datashare')
  end

  get '/' do
    arrest_reports = settings.db.collection("arrestReports")
    @reports = arrest_reports.find({},{limit: 15})
    haml :index
  end

  helpers ArrestReportHelper
end
