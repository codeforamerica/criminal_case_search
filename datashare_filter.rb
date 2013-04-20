require_relative "config/environment"

class DatashareFilter < Sinatra::Base
  QUERY_PREAMBLE = "arrest_report.e:EnterpriseDatashareDocument.e:DocumentBody.p:NYPDArrestTransaction.p:NYPDArrestReport.p:Arrest"
  register Sinatra::Twitter::Bootstrap::Assets

  configure do
    set :views, settings.root + '/app/views'
    set :haml, :format => :html5
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

    @reports = Incident.where(conditions).limit(15)
    haml :index
  end

  helpers ArrestReportHelper
  helpers ApplicationHelper
end
