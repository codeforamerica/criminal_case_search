require_relative "config/environment"
require_relative "authentication"

class DatashareFilter < Sinatra::Base
  # Root needs to be set before anything else. Things like :public_folder are dependent on it.
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "public") }

  BOROUGH_CODES_TO_NAMES = {"M" => "Manhattan", "S" => "Staten Island", "K" => "Brooklyn", "B" => "Bronx", "Q" => "Queens"}
  BOROUGH_CODES = %w(M S K B Q)

  register WillPaginate::Sinatra
  WillPaginate.per_page = 15

  if ENV["RACK_ENV"] != "development"
    use Authentication, "Protected Area", ['/.well-known/status'] do |username, password|
      username == ENV["CCS_USERNAME"] && password == ENV["CCS_PASSWORD"]
    end
  end

  set :assets_precompile, %w( application.js application.css *.png *.jpg *.svg *.eot *.ttf *.woff )
  set :assets_prefix, %w( app/assets )
  register Sinatra::AssetPipeline

  configure do
    set :views, settings.root + '/app/views'
    set :haml, :format => :html5
  end

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
