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

    if params["include-charge"]
      if params["include-charge"].include? "D"
        scope = scope.has_drug_charge
      end
      if params["include-charge"].include? "MA"
        scope = scope.has_misdemeanor_assault_charge
      end
      if params["include-charge"].include? "CC"
        scope = scope.has_criminal_contempt_charge
      end
      if params["include-charge"].include? "SO"
        scope = scope.has_sex_offense_charge
      end
      if params["include-charge"].include? "AA"
        scope = scope.has_untracked_charge
      end
    end

    scope
  end
end
