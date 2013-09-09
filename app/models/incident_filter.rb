class IncidentFilter

  def self.scope(params)
    scope = Incident.scoped

    if params[:borough]
      borough_names = params[:borough].map {|code| DatashareFilter::BOROUGH_CODES_TO_NAMES[code]}
      scope = scope.borough(borough_names)
    end

    if params["top-charge"]
      if params["top-charge"] == "VI"
        params["top-charge"] = %w(I V)
      end
      unless params["top-charge"] == "A"
        scope = scope.top_charge_in(params["top-charge"])
      end
    end

    scope
  end
end
