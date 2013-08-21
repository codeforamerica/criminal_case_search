require_relative "config/environment"

class SassHandler < Sinatra::Base   
  set :views, File.dirname(__FILE__) + '/app/assets/stylesheets'
    
  get '/css/*.css' do
    filename = params[:splat].first
    sass filename.to_sym
  end    
end

class DatashareFilter < Sinatra::Base
  use SassHandler
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

    if params[:filter][:borough]
      incident_scope = incident_scope.borough(params[:filter][:borough])
    end

    if params[:filter]["top-charge"].present?
      top_charge = params[:filter]["top-charge"]
      
      # Check the top charge code and make sure it's one we allow.
      # TODO: This should probably be in the model.
      if %w(I V M F).include?(top_charge)        
        incident_scope = incident_scope.top_charge(params[:filter]["top-charge"])
      else
        puts "Top charge '#{top_charge}' wasn't in the allowed charge list."                                                   
      end
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
