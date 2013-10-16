require_relative "config/environment"
require_relative "authentication"

class DatashareFilter < Sinatra::Base
  BOROUGH_CODES_TO_NAMES = {"M" => "Manhattan", "S" => "Staten Island", "K" => "Brooklyn", "B" => "Bronx", "Q" => "Queens"}
  BOROUGH_CODES = %w(M S K B Q)

  register WillPaginate::Sinatra
  WillPaginate.per_page = 15

  if ENV["RACK_ENV"] != "development"
    use Authentication, "Protected Area", ['/.well-known/status'] do |username, password|
      username == ENV["CCS_USERNAME"] && password == ENV["CCS_PASSWORD"]
    end
  end

  set :assets_path, settings.root + '/app/assets'
  register Sinatra::AssetPipeline
  sprockets.append_path(assets_path + "/javascripts")
  sprockets.append_path(assets_path + "/stylesheets")
  sprockets.append_path(assets_path + "/images")

  # binding.pry

  configure do
    set :views, settings.root + '/app/views'
    set :haml, :format => :html5
  end

  # binding.pry

  get '/' do
    puts params.inspect
    params[:filter] = {} unless params[:filter]
    
    @incidents = IncidentFilter.scope(params[:filter])

    if params[:format] == "csv"
      response.headers["Content-Type"]        = "text/csv; charset=UTF-8; header=present"
      response.headers["Content-Disposition"] = "attachment; filename=cases.csv"
      erb :export_csv
    else
      @incidents = @incidents.paginate(:page => (params[:page] || 1), :per_page => 15)
      haml :index
    end
  end

  get '/.well-known/status' do
    status = "ok"
    begin
      Incident.first
    rescue
      status = "down"
    end

    {
      status: status,
      updated: Time.now.to_i,
      dependencies: [],
      resources: {}
    }.to_json
  end

  helpers ApplicationHelper
end
