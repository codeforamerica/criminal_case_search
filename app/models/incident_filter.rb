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
      charge_types = []
      if params["include_charge"].include? "D"
        charge_types << "Drug"
      end
      if params["include_charge"].include? "MA"
        charge_types << "Misdemeanor Assault"
      end
      if params["include_charge"].include? "CC"
        charge_types << "Criminal Contempt"
      end
      if params["include_charge"].include? "SO"
        charge_types << "Sex Offense"
      end
      if params["include_charge"].include? "A"
        charge_types << "Untracked"
        charge_types << nil
      end
      scope = scope.charge_types_in(charge_types)
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

    if params["prior_convictions"]
      conviction_types = []
      if params["prior_convictions"].include? "D"
        conviction_types << "Drug"
      end
      if params["prior_convictions"].include? "MA"
        conviction_types << "Misdemeanor Assault"
      end
      if params["prior_convictions"].include? "CC"
        conviction_types << "Criminal Contempt"
      end
      if params["prior_convictions"].include? "SO"
        conviction_types << "Sex Offense"
      end
      if params["prior_convictions"].include? "A"
        conviction_types << "Untracked"
        conviction_types << nil
      end

      scope = scope.prior_conviction_types_in(conviction_types)
    end

    if params["number_of_prior_convictions"]
      if params["prior_conviction_bounds"] == "more"
        scope = scope.number_of_prior_criminal_convictions_gte(params["number_of_prior_convictions"])
      elsif params["prior_conviction_bounds"] == "fewer"
        scope = scope.number_of_prior_criminal_convictions_lte(params["number_of_prior_convictions"])
      end
    end

    if params["appearance_type"]
      if params["appearance_type"] == "arr"
        scope = scope.pre_arraignment
      elsif params["appearance_type"] == "post-arr"
        scope = scope.post_arraignment
      end
    end

    if params["next_court_date"]
      if params["next_court_date"] == "today"
        scope = scope.next_court_date_is(Date.today)
      elsif params["next_court_date"] == "tomorrow"
        scope = scope.next_court_date_is(Date.tomorrow)
      elsif params["next_court_date"] == "7-day"
        scope = scope.next_court_date_between(Date.today, Date.today + 7.days)
      end
    end

    scope
  end
end
