require_relative "config/environment"

class SassHandler < Sinatra::Base   
  set :views, File.dirname(__FILE__) + '/app/assets/stylesheets'
    
  get '/css/*.css' do
    filename = params[:splat].first
    sass filename.to_sym
  end    
end

class DatashareFilter < Sinatra::Base
  BOROUGH_CODES_TO_NAMES = {"M" => "Manhattan", "S" => "Staten Island", "K" => "Brooklyn", "B" => "Bronx", "Q" => "Queens"}
  BOROUGH_CODES = %w(M S K B Q)

  register Sinatra::Twitter::Bootstrap::Assets
  register WillPaginate::Sinatra
  use SassHandler

  WillPaginate.per_page = 15

  if ENV["RACK_ENV"] != "development"
    use Rack::Auth::Basic, "Protected Area" do |username, password|
      username == ENV["CCS_USERNAME"] && password == ENV["CCS_PASSWORD"]
    end
  end

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
      @incidents = @incidents.paginate(:page => params[:page])
      haml :index
    end
  end

  helpers ApplicationHelper
end
