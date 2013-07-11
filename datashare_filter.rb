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
      incident_scope = incident_scope.borough(params[:filter][:borough])
    end
    if params[:filter][:topcharge]
      incident_scope = incident_scope.top_charge(%w(I V)) if params[:filter][:topcharge] == "Non-Criminal"
      incident_scope = incident_scope.top_charge("M") if params[:filter][:topcharge] == "Misdemeanor"
      incident_scope = incident_scope.top_charge("F") if params[:filter][:topcharge] == "Felony"
    end
    if params[:filter][:sex]
      incident_scope = incident_scope.defendant_sex("M") if params[:filter][:sex] == "Male"
      incident_scope = incident_scope.defendant_sex("F") if params[:filter][:sex] == "Female"
    end
    if params[:filter][:min_age].present?
      incident_scope = incident_scope.defendant_age_gte(params[:filter][:min_age])
    end
    if params[:filter][:max_age].present?
      incident_scope = incident_scope.defendant_age_lte(params[:filter][:max_age])
    end
    ap incident_scope
    @incidents = incident_scope.where(:rap_sheet.exists => true, :docketing_notice.exists => true)

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
