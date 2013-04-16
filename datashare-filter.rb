require 'rubygems'
require 'bundler'
Bundler.require(:default)

include Mongo

configure do
  set :server, :puma

  client = MongoClient.new("localhost", 27017)
  set :mongo_client, client
  set :db, client.db('datashare')
end

get '/' do
  settings.db.collection("rapSheets").find_one().to_s
end
