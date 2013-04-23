require_relative "config/environment"

class DatashareFilter < Sinatra::Base
  QUERY_PREAMBLE = "arrest_report.e:EnterpriseDatashareDocument.e:DocumentBody.p:NYPDArrestTransaction.p:NYPDArrestReport.p:Arrest"
  register Sinatra::Twitter::Bootstrap::Assets

  configure do
    set :views, settings.root + '/app/views'
    set :haml, :format => :html5
  end

  get '/' do
    incident_scope = Incident.scoped
    params[:filter] = {} unless params[:filter]
    if params[:filter][:borough] && params[:filter][:borough] != "A"
      incident_scope = incident_scope.arrest_borough(params[:filter][:borough])
    end
    if params[:filter][:infraction]
      incident_scope = incident_scope.arrest_charges_include("I")
    end
    if params[:filter][:violation]
      incident_scope = incident_scope.arrest_charges_include("V")
    end
    if params[:filter][:misdemeanor]
      incident_scope = incident_scope.arrest_charges_include("M")
    end
    if params[:filter][:felony]
      incident_scope = incident_scope.arrest_charges_include("F")
    end

    @incidents = incident_scope.limit(15)
    haml :index
  end

  helpers ApplicationHelper
end
