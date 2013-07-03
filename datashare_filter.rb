require_relative "config/environment"

class DatashareFilter < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
  register WillPaginate::Sinatra

  WillPaginate.per_page = 15

  configure do
    set :views, settings.root + '/app/views'
    set :haml, :format => :html5
  end

  get '/' do
    puts params.inspect
    incident_scope = Incident.scoped
    params[:filter] = {} unless params[:filter]
    if params[:filter][:borough] && params[:filter][:borough] != "A"
      incident_scope = incident_scope.arrest_borough(params[:filter][:borough])
    end
    if params[:filter][:noncriminal]
      incident_scope = incident_scope.arrest_charges_include("I").arrest_charges_include("V")
    end
    if params[:filter][:misdemeanor]
      incident_scope = incident_scope.arrest_charges_include("M")
    end
    if params[:filter][:felony]
      incident_scope = incident_scope.arrest_charges_include("F")
    end
    if params[:filter][:sex]
      incident_scope = incident_scope.defendant_sex("M") if params[:filter][:sex] == "Male"
      incident_scope = incident_scope.defendant_sex("F") if params[:filter][:sex] == "Female"
    end

    @incidents = incident_scope.where(:arrest_report.exists => true).paginate(:page => params[:page])
    haml :index
  end

  helpers ApplicationHelper
end
