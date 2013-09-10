class IncidentFilter

  def self.scope(params)
    scope = Incident.scoped

    if params[:borough]
      borough_names = params[:borough].map {|code| DatashareFilter::BOROUGH_CODES_TO_NAMES[code]}
      scope = scope.borough(borough_names)
    end

    if params["top_charge"]
      if params["top_charge"] == "VI"
        params["top_charge"] = %w(I V)
      end
      unless params["top_charge"] == "A"
        scope = scope.top_charge_in(params["top_charge"])
      end
    end

    if params["include_charge"]
      if params["include_charge"].include? "D"
        scope = scope.has_drug_charge
      end
      if params["include_charge"].include? "MA"
        scope = scope.has_misdemeanor_assault_charge
      end
      if params["include_charge"].include? "CC"
        scope = scope.has_criminal_contempt_charge
      end
      if params["include_charge"].include? "SO"
        scope = scope.has_sex_offense_charge
      end
      if params["include_charge"].include? "AA"
        scope = scope.has_untracked_charge
      end
    end

    if params["sex"]
      unless params["sex"] == "A"
        scope = scope.defendant_sex(params["sex"])
      end
    end

    if params["min_age"].present?
      scope = scope.defendant_age_gte(params["min_age"])
    end

    if params["max_age"].present?
      scope = scope.defendant_age_lte(params["max_age"])
    end

    if params["open_cases"]
      if params["open_cases"] == "Y"
        scope = scope.has_other_open_cases
      elsif params["open_cases"] == "N"
        scope = scope.has_no_other_open_cases
      end
    end

    if params["failed_to_appear"]
      if params["failed_to_appear"] == "Y"
        scope = scope.has_failed_to_appear
      elsif params["failed_to_appear"] == "N"
        scope = scope.has_not_failed_to_appear
      end
    end
    scope
  end
end
