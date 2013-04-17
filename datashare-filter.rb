#TODO: rename with underscores
require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)
require './helpers/arrest_report_helper.rb'

class DatashareFilter < Sinatra::Base
  QUERY_PREAMBLE = "doc.e:EnterpriseDatashareDocument.e:DocumentBody.p:NYPDArrestTransaction.p:NYPDArrestReport.p:Arrest"
  include Mongo
  register Sinatra::Twitter::Bootstrap::Assets

  configure do
    set :haml, :format => :html5

    client = MongoClient.new("localhost", 27017)
    set :mongo_client, client
    set :db, client.db('datashare')
  end

  get '/' do
    conditions = {}
    params[:filter] = {} unless params[:filter]
    if params[:filter][:borough] && params[:filter][:borough] != "A"
      conditions.merge!({"#{QUERY_PREAMBLE}.p:ArrestLocation.p:LocationCountyCode" => params[:filter][:borough]})
    end
    if params[:filter][:infraction]
      conditions.merge!({"#{QUERY_PREAMBLE}.p:ArrestCharge.p:ChargeClassCode" => "I" })
    end
    if params[:filter][:violation]
      conditions.merge!({"#{QUERY_PREAMBLE}.p:ArrestCharge.p:ChargeClassCode" => "V" })
    end
    if params[:filter][:misdemeanor]
      conditions.merge!({"#{QUERY_PREAMBLE}.p:ArrestCharge.p:ChargeClassCode" => "M" })
    end
    if params[:filter][:felony]
      conditions.merge!({"#{QUERY_PREAMBLE}.p:ArrestCharge.p:ChargeClassCode" => "F" })
    end

    arrest_reports = settings.db.collection("arrestReports")

    @reports = arrest_reports.find(conditions).limit(15)
    haml :index
  end

  helpers ArrestReportHelper
end
